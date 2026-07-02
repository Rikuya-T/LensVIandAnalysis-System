import io
import os
import sys
from typing import List, Tuple

import pandas as pd
import streamlit as st


# Excel layout constants (1-based in spec -> 0-based in pandas)
ROW_START = 10  # Excel 11th row
ROW_END_EXCLUSIVE = 105  # Excel 105th row inclusive -> exclusive index 105
COL_INSPECTOR = 1  # B
COL_DATE = 3  # D
COL_MODEL = 4  # E
COL_LOT_TOTAL = 6  # G
COL_SAMPLE_TOTAL = 7  # H
COL_FAIL_TOTAL = 9  # J
COL_DEFECT_START = 10  # K
COL_DEFECT_END = 75  # BX
HEADER_ROW_DEFECT = 2  # Excel row 3


@st.cache_data
def list_sheet_names(file_bytes: bytes) -> List[str]:
    excel_file = pd.ExcelFile(io.BytesIO(file_bytes), engine="openpyxl")
    return excel_file.sheet_names


@st.cache_data
def parse_workbook(file_bytes: bytes, sheet_name: str) -> Tuple[pd.DataFrame, List[str]]:
    """Read workbook and reshape specified range to analysis-friendly table."""
    raw = pd.read_excel(io.BytesIO(file_bytes), header=None, sheet_name=sheet_name)

    required_cols = COL_DEFECT_END + 1
    required_rows = ROW_END_EXCLUSIVE
    if raw.shape[1] < required_cols or raw.shape[0] < required_rows:
        raise ValueError(
            "指定範囲（B11:BX105）を読み取れません。シートの列数・行数を確認してください。"
        )

    defect_names = (
        raw.iloc[HEADER_ROW_DEFECT, COL_DEFECT_START : COL_DEFECT_END + 1]
        .fillna("")
        .astype(str)
        .str.strip()
        .tolist()
    )

    # Empty headers are replaced to keep column uniqueness.
    normalized_defect_names: List[str] = []
    for idx, name in enumerate(defect_names, start=1):
        normalized_defect_names.append(name if name else f"不適合項目_{idx}")

    records = raw.iloc[ROW_START:ROW_END_EXCLUSIVE, :].copy()
    records = records.reset_index(drop=True)

    base_df = pd.DataFrame(
        {
            "検査員": records.iloc[:, COL_INSPECTOR],
            "検査日": records.iloc[:, COL_DATE],
            "機種": records.iloc[:, COL_MODEL],
            "ロット総数": records.iloc[:, COL_LOT_TOTAL],
            "サンプル数": records.iloc[:, COL_SAMPLE_TOTAL],
            "不合格数": records.iloc[:, COL_FAIL_TOTAL],
        }
    )

    defect_df = records.iloc[:, COL_DEFECT_START : COL_DEFECT_END + 1].copy()
    defect_df.columns = normalized_defect_names

    merged_df = pd.concat([base_df, defect_df], axis=1)

    # Normalize types
    merged_df["検査員"] = merged_df["検査員"].fillna("").astype(str).str.strip()
    merged_df["機種"] = merged_df["機種"].fillna("").astype(str).str.strip()

    merged_df["検査日"] = pd.to_datetime(merged_df["検査日"], errors="coerce")

    for col in ["ロット総数", "サンプル数", "不合格数"] + normalized_defect_names:
        merged_df[col] = pd.to_numeric(merged_df[col], errors="coerce").fillna(0)

    # Ignore rows without core keys.
    merged_df = merged_df[(merged_df["検査員"] != "") & (merged_df["機種"] != "")].copy()

    return merged_df, normalized_defect_names


def summarize_dimension(df: pd.DataFrame, key_col: str, defect_cols: List[str]) -> pd.DataFrame:
    grouped = (
        df.groupby(key_col, dropna=False)
        .agg(
            検査件数=(key_col, "count"),
            ロット総数=("ロット総数", "sum"),
            サンプル数=("サンプル数", "sum"),
            不合格数=("不合格数", "sum"),
        )
        .reset_index()
    )

    grouped["不良率(%)"] = grouped.apply(
        lambda r: (r["不合格数"] / r["サンプル数"] * 100) if r["サンプル数"] > 0 else 0,
        axis=1,
    )

    defect_sum = df.groupby(key_col, dropna=False)[defect_cols].sum().reset_index()
    merged = grouped.merge(defect_sum, on=key_col, how="left")

    return merged.sort_values("不良率(%)", ascending=False)


def top_defects(df: pd.DataFrame, defect_cols: List[str], top_n: int = 10) -> pd.DataFrame:
    sums = df[defect_cols].sum().sort_values(ascending=False)
    top_items = sums.head(top_n)

    rows = []
    for defect_name, defect_count in top_items.items():
        model_breakdown = (
            df.groupby("機種", dropna=False)[defect_name]
            .sum()
            .sort_values(ascending=False)
        )
        model_breakdown = model_breakdown[model_breakdown > 0]

        breakdown_text = " / ".join(
            f"{model_name}:{int(count) if float(count).is_integer() else round(float(count), 2)}"
            for model_name, count in model_breakdown.items()
        )

        rows.append(
            {
                "不適合項目": defect_name,
                "検出数": defect_count,
                "機種別内訳": breakdown_text,
            }
        )

    return pd.DataFrame(rows)


def detect_issues(summary_df: pd.DataFrame, key_col: str, fail_rate_threshold: float) -> pd.DataFrame:
    flagged = summary_df[summary_df["不良率(%)"] >= fail_rate_threshold].copy()
    return flagged[[key_col, "検査件数", "サンプル数", "不合格数", "不良率(%)"]]


def ensure_streamlit_context() -> None:
    """Allow launching via `python app.py` by re-invoking Streamlit CLI."""
    runtime_exists = False
    try:
        from streamlit.runtime import exists as runtime_exists_fn

        runtime_exists = runtime_exists_fn()
    except Exception:
        runtime_exists = False

    if runtime_exists:
        return

    try:
        from streamlit.web import cli as stcli
    except Exception:
        print("streamlit が見つかりません。`pip install -r requirements.txt` を実行してください。")
        raise

    sys.argv = ["streamlit", "run", os.path.abspath(__file__)]
    raise SystemExit(stcli.main())


ensure_streamlit_context()

st.set_page_config(page_title="外観検査分析システム", layout="wide")
st.title("外観検査分析システム")
st.caption("XLSXを都度選択して、機種別・検査員別の不良傾向を可視化します。")


uploaded = st.file_uploader("分析対象のXLSXファイルを選択してください", type=["xlsx"])

if uploaded is None:
    st.info("左の入力欄からXLSXファイルを選択すると分析を開始します。")
    st.stop()

file_bytes = uploaded.getvalue()

try:
    sheet_names = list_sheet_names(file_bytes)
except Exception as ex:
    st.error("シート情報の読み込みに失敗しました。ファイル形式をご確認ください。")
    st.exception(ex)
    st.stop()

selected_sheet = st.selectbox("解析対象シートを選択してください", options=sheet_names, index=0)

try:
    data_df, defect_columns = parse_workbook(file_bytes, selected_sheet)
except Exception as ex:
    st.error("ファイルの読み込みに失敗しました。フォーマットをご確認ください。")
    st.exception(ex)
    st.stop()

if data_df.empty:
    st.warning("有効なデータ行が見つかりませんでした。指定セル範囲を確認してください。")
    st.stop()

st.subheader("読み込み結果")
col1, col2, col3 = st.columns(3)
col1.metric("データ件数", f"{len(data_df):,}")
col2.metric("機種数", f"{data_df['機種'].nunique():,}")
col3.metric("検査員数", f"{data_df['検査員'].nunique():,}")

with st.expander("読み込みデータ（先頭20件）", expanded=False):
    st.dataframe(data_df.head(20), use_container_width=True)

st.subheader("分析条件")
threshold = st.slider("課題抽出の不良率しきい値（%）", min_value=0.0, max_value=100.0, value=5.0, step=0.5)

# Model-based analysis
st.subheader("機種別分析")
model_summary = summarize_dimension(data_df, "機種", defect_columns)
st.dataframe(
    model_summary[["機種", "検査件数", "ロット総数", "サンプル数", "不合格数", "不良率(%)"]],
    use_container_width=True,
)

model_issues = detect_issues(model_summary, "機種", threshold)
st.markdown("課題候補（機種別）")
if model_issues.empty:
    st.success("しきい値以上の機種はありません。")
else:
    st.dataframe(model_issues, use_container_width=True)

# Inspector-based analysis
st.subheader("検査員別分析")
inspector_summary = summarize_dimension(data_df, "検査員", defect_columns)
st.dataframe(
    inspector_summary[["検査員", "検査件数", "ロット総数", "サンプル数", "不合格数", "不良率(%)"]],
    use_container_width=True,
)

inspector_issues = detect_issues(inspector_summary, "検査員", threshold)
st.markdown("課題候補（検査員別）")
if inspector_issues.empty:
    st.success("しきい値以上の検査員はありません。")
else:
    st.dataframe(inspector_issues, use_container_width=True)

# Defect item trend
st.subheader("不適合項目の上位傾向")
top_model = st.selectbox("対象機種（不適合項目確認）", options=["全機種"] + sorted(data_df["機種"].unique().tolist()))
top_inspector = st.selectbox("対象検査員（不適合項目確認）", options=["全検査員"] + sorted(data_df["検査員"].unique().tolist()))

filtered = data_df.copy()
if top_model != "全機種":
    filtered = filtered[filtered["機種"] == top_model]
if top_inspector != "全検査員":
    filtered = filtered[filtered["検査員"] == top_inspector]

if filtered.empty:
    st.warning("選択条件に一致するデータがありません。")
else:
    top_defect_df = top_defects(filtered, defect_columns, top_n=15)
    st.dataframe(top_defect_df, use_container_width=True)
    st.bar_chart(top_defect_df.set_index("不適合項目")[["検出数"]])

# CSV export
st.subheader("集計結果のダウンロード")
output = io.BytesIO()
with pd.ExcelWriter(output, engine="openpyxl") as writer:
    model_summary.to_excel(writer, index=False, sheet_name="機種別集計")
    inspector_summary.to_excel(writer, index=False, sheet_name="検査員別集計")
    top_defects(data_df, defect_columns, top_n=30).to_excel(writer, index=False, sheet_name="不適合項目上位")

st.download_button(
    label="集計結果をExcelで保存",
    data=output.getvalue(),
    file_name="外観検査_分析結果.xlsx",
    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
)
