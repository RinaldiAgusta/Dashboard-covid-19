-- Pertama, kita buat tabel untuk menyimpan data dari CSV
CREATE TABLE covid_indonesia (
    Date DATE,
    Location_ISO_Code VARCHAR(10),
    Location VARCHAR(255),
    New_Cases INT,
    New_Deaths INT,
    New_Recovered INT,
    New_Active_Cases INT,
    Total_Cases INT,
    Total_Deaths INT,
    Total_Recovered INT,
    Total_Active_Cases INT,
    Location_Level VARCHAR(50),
    City_or_Regency VARCHAR(255),
    Province VARCHAR(255),
    Country VARCHAR(255),
    Continent VARCHAR(255),
    Island VARCHAR(255),
    Time_Zone VARCHAR(50),
    Special_Status VARCHAR(255),
    Total_Regencies INT,
    Total_Cities INT,
    Total_Districts INT,
    Total_Urban_Villages INT,
    Total_Rural_Villages INT,
    Area_km2 DECIMAL(10,2),
    Population INT,
    Population_Density DECIMAL(10,2),
    Longitude DECIMAL(10,6),
    Latitude DECIMAL(10,6),
    New_Cases_per_Million DECIMAL(10,2),
    Total_Cases_per_Million DECIMAL(10,2),
    New_Deaths_per_Million DECIMAL(10,2),
    Total_Deaths_per_Million DECIMAL(10,2),
    Total_Deaths_per_100k DECIMAL(10,2),
    Case_Fatality_Rate DECIMAL(5,2),
    Case_Recovered_Rate DECIMAL(5,2),
    Growth_Factor_of_New_Cases DECIMAL(5,2),
    Growth_Factor_of_New_Deaths DECIMAL(5,2)
);

-- Misalkan kita sudah mengimpor data CSV ke dalam tabel sementara
-- Selanjutnya, kita lakukan pembersihan data dengan query berikut

-- Menghapus duplikat berdasarkan kolom 'Date' dan 'Location'
DELETE FROM covid_indonesia
WHERE (Date, Location) IN (
    SELECT Date, Location
    FROM (
        SELECT Date, Location, ROW_NUMBER() OVER (PARTITION BY Date, Location ORDER BY Date) AS rnum
        FROM covid_indonesia
    ) t
    WHERE rnum > 1
);

-- Menghapus baris dengan nilai NULL pada kolom yang penting
DELETE FROM covid_indonesia
WHERE Date IS NULL
   OR Location IS NULL
   OR New_Cases IS NULL
   OR New_Deaths IS NULL;

-- Mengoreksi nilai yang tidak valid seperti angka negatif untuk kolom yang seharusnya positif
UPDATE covid_indonesia
SET New_Cases = NULL
WHERE New_Cases < 0;

UPDATE covid_indonesia
SET New_Deaths = NULL
WHERE New_Deaths < 0;

UPDATE covid_indonesia
SET Population_Density = NULL
WHERE Population_Density < 0;

-- Memperbaiki format tanggal jika diperlukan (misal, memastikan format YYYY-MM-DD)
-- Misalkan kita hanya memilih data yang format tanggalnya benar
UPDATE covid_indonesia
SET Date = NULL
WHERE Date NOT BETWEEN '2020-01-01' AND '2099-12-31';

-- Menyaring data untuk memastikan konsistensi nilai
-- Misal, nilai 'Total_Cases' harus lebih besar dari 'New_Cases'
UPDATE covid_indonesia
SET Total_Cases = NULL
WHERE Total_Cases < New_Cases;

-- Menghapus data yang tidak lengkap atau tidak konsisten
DELETE FROM covid_indonesia
WHERE Total_Deaths IS NULL
   OR Total_Recovered IS NULL
   OR Area_km2 IS NULL
   OR Population IS NULL
   OR Longitude IS NULL
   OR Latitude IS NULL;

-- Periksa apakah ada nilai yang tidak konsisten dalam persentase dan rasio
-- Misal, 'Case_Fatality_Rate' harus berada di antara 0 dan 100
UPDATE covid_indonesia
SET Case_Fatality_Rate = NULL
WHERE Case_Fatality_Rate < 0 OR Case_Fatality_Rate > 100;

-- Melakukan pembaruan akhir untuk konsistensi data
-- Menghapus nilai duplikat atau anomali lebih lanjut jika diperlukan
