import streamlit as st
import pandas as pd

# ── Page setup ───────────────────────────────────────────────────────────
st.set_page_config(page_title="UK College Contact Hours", page_icon="🎓", layout="wide")

st.title("🎓 UK College Contact Learning Hours Analysis")
st.subheader("How Institution Type, Region, and Size Affect Learning Delivery")

st.markdown(
    "A statistical investigation into contact learning hours (CH) across "
    "**311 UK Further Education and Sixth Form colleges**, examining how "
    "institution type, geographic region, and college size affect learning "
    "delivery, graduation outcomes, and student value add."
)

st.caption(
    "📌 The statistical analysis (ANOVA, regression) behind this project was "
    "conducted in **SAS 9.4**. This app presents those findings alongside a "
    "live, interactive exploration of the cleaned dataset, powered by pandas."
)

st.divider()

# ── Load data ────────────────────────────────────────────────────────────
@st.cache_data
def load_data():
    df = pd.read_csv("data/AllColleges_clean.csv")
    return df

df = load_data()

# ── Section 1: Key Findings ─────────────────────────────────────────────
st.header("1. Key Findings")

col1, col2, col3 = st.columns(3)
with col1:
    st.metric("Sixth Form avg. CH/Learner", "430.9 hrs", help="SD = 136.33")
with col2:
    st.metric("FE College avg. CH/Learner", "190.5 hrs", help="SD = 60.41")
with col3:
    st.metric("VAF explains variance in CH", "28.2%", help="R² = 0.2824, p < 0.0001")

st.markdown("""
- **Sixth Form colleges deliver roughly 2x more contact hours per learner** than FE colleges —
  a difference confirmed significant by two-way ANOVA (F(1,294)=277.96, p<0.0001), and consistent
  across all nine English regions.
- **Institution type and region interact significantly** (F(8,294)=3.29, p=0.0013) — regional
  differences in contact hours are not uniform across college types.
- **Value Add Factor (VAF) is the strongest predictor** of both contact hours and graduation
  outcomes — stronger than contact hours itself in predicting graduation pass rate.
- **Contact hours changed significantly across the three academic years studied**
  (F(2,909)=3.24, p=0.0395).
- **Sixth Form colleges also achieve higher graduation pass rates** (84.98% vs 82.45%, p=0.0041).
""")

st.divider()

# ── Section 2: Charts ────────────────────────────────────────────────────
st.header("2. Charts")

chart_col1, chart_col2 = st.columns(2)
with chart_col1:
    st.image("outputs/CHperLearner_by_Institution_Type__boxplot_.png",
              caption="CHperLearner by Institution Type")
    st.image("outputs/Distribution_of_CHperLearner__histogram_.png",
              caption="Distribution of CHperLearner (all colleges)")
with chart_col2:
    st.image("outputs/CHperLearner_by_Region_and_Institution__boxplot_.png",
              caption="CHperLearner by Region and Institution Type")
    st.image("outputs/Value_Add_Factor_by_Region__boxplot_.png",
              caption="Value Add Factor by Region")

st.image("outputs/Gender_composition_by_Institution_Type__boxplot_.png",
          caption="Gender Composition by Institution Type", width=500)

st.divider()

# ── Section 3: Live Data Explorer ────────────────────────────────────────
st.header("3. Explore the Data Yourself")

st.markdown(
    "Unlike the charts above (generated in SAS), the table and summary below "
    "are computed **live** from the cleaned dataset using this filter."
)

col1, col2 = st.columns(2)
with col1:
    institution_filter = st.selectbox(
        "Institution Type",
        ["All"] + sorted(df["Institution"].dropna().unique().tolist())
    )
with col2:
    region_filter = st.selectbox(
        "Region",
        ["All"] + sorted(df["Region"].dropna().unique().tolist())
    )

filtered = df.copy()
if institution_filter != "All":
    filtered = filtered[filtered["Institution"] == institution_filter]
if region_filter != "All":
    filtered = filtered[filtered["Region"] == region_filter]

st.write(f"**{len(filtered)} colleges** match this selection")

if len(filtered) > 0:
    m1, m2, m3, m4 = st.columns(4)
    m1.metric("Avg CH per Learner", f"{filtered['CHperLearner'].mean():.1f}")
    m2.metric("Avg Graduation Rate", f"{filtered['GradPR'].mean():.2%}")
    m3.metric("Avg Value Add Factor", f"{filtered['VAF'].mean():.2f}")
    m4.metric("Avg % Female Students", f"{filtered['GPercentFemale'].mean():.1f}%")

    st.dataframe(
        filtered[["Institution", "Region", "SizeCategory", "CHperLearner",
                  "GradPR", "VAF", "GPercentFemale"]].reset_index(drop=True),
        use_container_width=True,
        height=300
    )
else:
    st.info("No colleges match this combination — try a different filter.")

st.divider()

# ── About ─────────────────────────────────────────────────────────────────
st.header("About This Project")

st.markdown("""
**Methodology**

The cleaned dataset (311 colleges, after IQR-based outlier removal) was
built in SAS from three source files: contact hours and learner counts for
Sixth Form and FE colleges, and a separate metrics file linking graduation
pass rates and value add factors by institution ID.

Statistical analysis used `PROC GLM` (one-way and two-way ANOVA with
Levene's test and LSD post-hoc), `PROC REG` (simple and multiple
regression with VIF and Cook's D), `PROC CORR`, and `PROC UNIVARIATE` for
residual diagnostics.

**Limitations**

Levene's test indicated unequal variances across Region groups, and
residuals showed some departure from normality — both common with
real-world educational data, and the sample size of 311 colleges provides
reasonable robustness to moderate violations.

**Full project**: complete methodology, all findings, and the SAS code are
documented in the
[GitHub repository](https://github.com/s4sydney/UK-College-Contact-Hours-Analysis).
""")

st.caption("Built by Sydney Ndabai · MSc Data Analytics")
