/*

Cleaning Data in SQL Queries

*/


Select * from [Portfolio Project]..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Standardize date format

Select SaleDate, CONVERT(date, SaleDate)
from [Portfolio Project]..NashvilleHousing

Alter table [Portfolio Project]..NashvilleHousing
ALter Column SaleDate DATE


--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address Data

Select *
from [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


-- Populate PropertyAddres, with another property address where parcelId is same

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNUll(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] != b.[UniqueID ]
	Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNUll(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Idividual Columns (Address, City, State)
s
Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) as Address1
from [Portfolio Project]..NashvilleHousing




-- Create New Columns for seperated Address


Alter table NashvilleHousing
Add PropertySplitAddress nvarchar (255);


Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)


Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)


Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) 


Select * from NashvilleHousing


Select OwnerAddress
from NashvilleHousing


-- Breaking out owner address using parsename

Select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from [Portfolio Project]..NashvilleHousing

-- Create new Columns

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

-- Add data in new columns

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)



--------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to 'Yes' and 'No' in 'Sold as Vacant' Field

Select SoldAsVacant
From [Portfolio Project]..NashvilleHousing
Where SoldAsVacant = 'Y' or SoldAsVacant = 'N'

Update [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE
						When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
				   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2



-- Remove Duplicates --


With RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
from [Portfolio Project]..NashvilleHousing
--Order by ParcelID
)
Select * from RowNumCTE Where row_num>1


--------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

Select * from [Portfolio Project]..NashvilleHousing

Alter Table NashvilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict