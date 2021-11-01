
/*

Cleaning Data using SQL Queries

*/

-- Data structure we are working on
Select SoldAsVacant From PortfolioProject..CityHousing


-- Standardize Date Format
Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProject..CityHousing

-- Update CityHousing
-- Set SaleDate = CONVERT(Date, SaleDate) // actually not working

Alter Table CityHousing
Add SaleDateConverted Date

Update CityHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate property Address data
Select * --PropertyAddress
From PortfolioProject..CityHousing
--Where PropertyAddress is NULL
Order by ParcelID
--

Select ct1.ParcelID, ct1.PropertyAddress, ct2.ParcelID, ct2.PropertyAddress, ISNULL(ct1.PropertyAddress, ct2.PropertyAddress)
From PortfolioProject..CityHousing ct1
JOIN PortfolioProject..CityHousing ct2
	ON ct1.ParcelID = ct2.ParcelID
	AND ct1.UniqueID <> ct2.UniqueID
Where ct1.PropertyAddress is NULL

Update ct1
Set PropertyAddress = ISNULL(ct1.PropertyAddress, ct2.PropertyAddress)
From PortfolioProject..CityHousing ct1
JOIN PortfolioProject..CityHousing ct2
	ON ct1.ParcelID = ct2.ParcelID
	AND ct1.UniqueID <> ct2.UniqueID
Where ct1.PropertyAddress is NULL


-- Breaking out Addresses into individual Columns (Address, City, State)

---------------------- HANDLE PropertyAddress
Select PropertyAddress
From PortfolioProject..CityHousing
--Where PropertyAddress is NULL
--Order by ParcelID

Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject..CityHousing

Alter Table CityHousing
Add PropertyAddressSplitted nvarchar(255);

Update CityHousing
Set PropertyAddressSplitted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table CityHousing
Add PropertyCitySplitted nvarchar(255)

Update CityHousing
Set PropertyCitySplitted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

---------------------- HANDLE OwnerAddress
Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State,
	OwnerAddress
From PortfolioProject..CityHousing
Where OwnerAddress IS NOT NULL

Alter Table CityHousing
Add OwnerSplitAddress nvarchar(255);

Update CityHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table CityHousing
Add OwnerSplitCity nvarchar(255);

Update CityHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table CityHousing
Add OwnerSplitState nvarchar(255);

Update CityHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes And No in "Sold as Vacant" Field


Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..CityHousing
Group by SoldAsVacant
Order by 2
--/
Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
From PortfolioProject..CityHousing
--/
Update PortfolioProject..CityHousing
Set SoldAsVacant = 
					CASE When SoldAsVacant = 'Y' THEN 'Yes'
						 When SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
					END;


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				 ORDER BY UniqueID ) row_num
From PortfolioProject..CityHousing
--Order by ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete unused Columns (OwnerAddress, TaxDistrict, PropertyAddress, SaleDate)

Select * FROM PortfolioProject..CityHousing

ALTER TABLE PortfolioProject..CityHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..CityHousing
DROP COLUMN SaleDate