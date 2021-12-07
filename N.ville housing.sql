select * from PortfolioProject.dbo.NashvilleHousing;

--Standardizing date format
Select SaleDate,cast(SaleDate AS DATE) from PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing SET SaleDate=cast(SaleDate AS DATE);

Select SaleDate from PortfolioProject..NashvilleHousing;

Alter TABLE PortfolioProject..NashvilleHousing 
ADD SaleDateConverted DATE;

SELECT SaleDateConverted from PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing SET SaleDateConverted=cast(SaleDate AS DATE);

--Populating property address data 

select PropertyAddress from PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

SELECT * FROM PortfolioProject.dbo.NashvilleHousing order by ParcelID;

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a JOIN 
PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID=B.ParcelID and
a.UniqueID<>b.UniqueID WHERE a.PropertyAddress IS NULL;

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a JOIN 
PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID=B.ParcelID and
a.UniqueID<>b.UniqueID WHERE a.PropertyAddress IS NULL;


--Breaking out Property address into individual columns using SUBSTRING,CHARINDEX


SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT PropertySplitAddress,PropertySplitCity from PortfolioProject.dbo.NashvilleHousing;


--Breaking out Owner address into individual columns using PARSENAME

SELECT OwnerAddress from PortfolioProject.dbo.NashvilleHousing;

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select * from PortfolioProject.dbo.NashvilleHousing;


--Changing Y and N to Yes and No in the 'SoldAsVacant' field 
SELECT distinct(SoldAsVacant),count(SoldAsVacant) from PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant ORDER BY 2;


SELECT SoldAsVacant 
	,CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
         ELSE SoldAsVacant
    END
from PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
         ELSE SoldAsVacant
    END


--Remove Duplicate

With Rownum_cte AS(
SELECT *,
ROW_NUMBER()
OVER (PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueID)row_num
from PortfolioProject.dbo.NashvilleHousing --ORDER BY ParcelID;
)
DELETE FROM Rownum_cte WHERE row_num>1;



--Delete unused columns

SELECT * from PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate;








