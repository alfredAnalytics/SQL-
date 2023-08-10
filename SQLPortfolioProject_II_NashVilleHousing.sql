--Data Cleaning
select*
from SQLTutorial..NashvilleHousing

----Sale Date

select SalesDateConverted, CONVERT(date,SaleDate)
from SQLTutorial..NashvilleHousing

update SQLTutorial..NashvilleHousing
set Saledate = CONVERT(date,SaleDate)

alter table SQLTutorial..NashvilleHousing
add SalesDateConverted  date;

update SQLTutorial..NashvilleHousing
set SalesDateConverted = convert(date,SaleDate)

--Property adress data

select PropertyAddress
from SQLTutorial..NashvilleHousing

--populating the empty  PropertyAddress

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from SQLTutorial..NashvilleHousing a
join SQLTutorial..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set a.PropertyAddress =isnull(a.PropertyAddress, b.PropertyAddress)
 from SQLTutorial..NashvilleHousing a
join SQLTutorial..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--beaking address into separate columns (address, city, state)

select PropertyAddress
from SQLTutorial..NashvilleHousing

select
substring(PropertyAddress,1, charindex(',',PropertyAddress) -1) as address,
substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress)) as address

from SQLTutorial..NashvilleHousing

alter table SQLTutorial..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update SQLTutorial..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1, charindex(',',PropertyAddress) -1)


alter table SQLTutorial..NashvilleHousing
add PropertySplitCity nvarchar(255);

update SQLTutorial..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress))


select* 
from SQLTutorial..NashvilleHousing



select OwnerAddress
from SQLTutorial..NashvilleHousing


select
parsename(replace(OwnerAddress, ',', '.'),3) as address,
parsename(replace(OwnerAddress, ',', '.'),2) as city,
parsename(replace(OwnerAddress, ',', '.'),1) as state
from SQLTutorial..NashvilleHousing
--where OwnerAddress is not null

alter table SQLTutorial..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update SQLTutorial..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3)


alter table SQLTutorial..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update SQLTutorial..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),2)

alter table SQLTutorial..NashvilleHousing
add OwnerSplitState nvarchar(255);

update SQLTutorial..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'),1)


select* 
from SQLTutorial..NashvilleHousing

--Yes/No options for SoldAsVacant column
select distinct(soldAsVacant), Count(soldAsVacant)
from SQLTutorial..NashvilleHousing
group by soldasvacant
order by 2


select soldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes' 
     when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 end

from SQLTutorial..NashvilleHousing

update SQLTutorial..NashvilleHousing
set 
soldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes' 
     when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 end

--Remove duplicates

with RowNumCTE as (
select*,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 order by
				 UniqueID ) row_num
from SQLTutorial..NashvilleHousing
--order by ParcelID
)

select*
From RowNumCTE
where row_num > 1
order by PropertyAddress


--Delete Unused Columns

select *
from SQLTutorial..NashvilleHousing

alter table SQLTutorial..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table SQLTutorial..NashvilleHousing
drop column SaleDate