/*
Cleaning data in SQl

*/

select *
from PortifolioProject1..NashVilleHousing

-- standardize date format


update NashVilleHousing
set SaleDate = CONVERT(date,saleDate)

alter table NashVilleHousing
add saleDateConverted Date;

update NashVilleHousing
set SaleDateConverted = Convert(Date,SaleDate)

-- Populate Property Address data
select *
from PortifolioProject1..NashVilleHousing
--where PropertyAddress is null
order by ParcelID

-- * now we'll join the same table on top of each other base on parcelid, with UniqueID not the same

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortifolioProject1..NashVilleHousing a
join PortifolioProject1..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress is null

-- we will have to update our table

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortifolioProject1..NashVilleHousing a
join PortifolioProject1..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress is null

-- then we check again by running the below query, to be sure our update works, and the null values will disappear.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortifolioProject1..NashVilleHousing a
join PortifolioProject1..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress is null

-- Breakingout address into individual columns (Address, City, States)
-- Let's look into the property address to take a look at the structure of the address

select PropertyAddress
from PortifolioProject1..NashVilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING (PropertyAddress,1, charindex(',', PropertyAddress)-1) as Address
from PortifolioProject1..NashVilleHousing

ALTER TABLE NashVilleHousing
	ADD PropertysplitAddress nvarchar(255);

update NashVilleHousing
SET PropertysplitAddress = SUBSTRING (PropertyAddress,1, charindex(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
ADD PropertysplitCity nvarchar(255);

update NashVilleHousing
SET PropertysplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortifolioProject1..NashVilleHousing

select OwnerAddress
from PortifolioProject1..NashVilleHousing

-- another way to split out the address content
select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortifolioProject1..NashVilleHousing

Alter table NashVilleHousing
add OnwersplitAddress nvarchar(255);

update NashVilleHousing
SET OnwersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter table NashVilleHousing
add OnwersplitCity nvarchar(255);

update NashVilleHousing
SET OnwersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table NashVilleHousing
add OnwersplitState nvarchar(255);

update NashVilleHousing
SET OnwersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select*
from PortifolioProject1..NashVilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field.
-- to be sure of what we have in the column, we do a distinct select.

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortifolioProject1..NashVilleHousing
group by SoldAsVacant
order by 2

--Then we do a case statement.

select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
from PortifolioProject1..NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortifolioProject1..NashVilleHousing
group by SoldAsVacant
order by 2

-- Remove Duplicate

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER( PARTITION BY ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference
							ORDER BY UniqueID) row_num

FROM PortifolioProject1..NashVilleHousing
-- ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-- to confirm the rows have been deleted

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER( PARTITION BY ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference
							ORDER BY UniqueID) row_num

FROM PortifolioProject1..NashVilleHousing
-- ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Remove unused columns

SELECT *
FROM PortifolioProject1..NashVilleHousing

ALTER TABLE NashVilleHousing
DROP COLUMN PropertyAddress, TaxDistrict,PropersplitAddress,PropersplitCity

ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress