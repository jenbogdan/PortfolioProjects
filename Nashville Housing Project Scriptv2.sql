/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted, CONVERT(Date,SaleDate)
From NashvilleProject.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- if the parcelid is duplicated, make the property addresses the same (if one has address and one doesn't)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]       
Where a.PropertyAddress is null


Update a       
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- after running the update, run the above select statement again. there should be 0 results


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- (property address and owner address)

Select PropertyAddress
From NashvilleProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- currently address, city
-- separate on the comma because there no other commas except the delimiter


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address     
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address 

From NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


select *
From NashvilleProject.dbo.NashvilleHousing





Select OwnerAddress
From NashvilleProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleProject.dbo.NashvilleHousing



ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From NashvilleProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleProject.dbo.NashvilleHousing


Update NashvilleProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates using row number, can also be done using rank

-- we are deleting data, probably not done this way in real life

WITH RowNumCTE AS(  
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, -- partition by fields that should be unique
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--if row_num > 1 then we know its a duplicate

DELETE --(comment out above select statement before deleting)
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From NashvilleProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns -- used when creating views. do not do this on raw data


Select *
From NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


















