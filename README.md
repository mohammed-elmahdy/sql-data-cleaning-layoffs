# 🧹 SQL Data Cleaning Project – Layoffs Dataset

## 📌 Overview

This project focuses on cleaning and preparing a raw layoffs dataset using MySQL.
The goal is to transform messy data into a structured and analysis-ready format.

---

## 🛠️ Tools Used

* MySQL
* SQL (Window Functions, Joins, CTEs)

---

## 📂 Dataset

The dataset contains information about global layoffs, including:

* Company
* Location
* Industry
* Total Laid Off
* Date
* Country
* Funding

---

## ⚙️ Data Cleaning Steps

The following steps were performed:

1. **Data Inspection**

   * Checked structure and row counts

2. **Staging Table Creation**

   * Created a copy of raw data to preserve original dataset

3. **Duplicate Removal**

   * Used `ROW_NUMBER()` to identify and remove duplicates

4. **Data Standardization**

   * Trimmed text fields
   * Standardized industry names
   * Fixed inconsistent country values
   * Converted date format

5. **Handling Missing Values**

   * Replaced blanks with NULLs
   * Filled missing values using self-joins
   * Removed irrelevant rows

6. **Final Cleanup**

   * Dropped helper columns
   * Created a final cleaned dataset

---

## 📁 Project Structure

```
📦 sql-data-cleaning-layoffs
 ┣ 📜 data_cleaning.sql
 ┣ 📄 README.md
 ┗ 📊 screenshots/ (optional)
```

---

## 📬 Author

**Mohammed Elmahdy**
