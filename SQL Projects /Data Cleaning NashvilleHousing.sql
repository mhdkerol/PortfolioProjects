SELECT *
FROM PortfolioProject..NashvilleHousing


--Standardize Date Format


SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)




---Since the data doesn't update properly, we use the 'ALTER TABLE' statement to create a new column.

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




--Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] = b.[UniqueID ]
WHERE a.PropertyAddress IS NULL




--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing




SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	 , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	 , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing




ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar (255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject.. NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing  
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




SELECT *
FROM PortfolioProject..NashvilleHousing




--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
						
						
						
						
--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--Check if there is any duplicates left

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1




--Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
