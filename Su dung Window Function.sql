--Case 01: Xếp hạng thống kê doanh thu theo mã nhân viên tại thời điểm quý 4 năm 2023

Drop table #cte01
Select 
	SalesPersonID MaNV,
	SUM(SubTotal) TongDT
	INTO #cte01
From Sales.SalesOrderHeader
Where YEAR(OrderDate)=2013 and DATEPART(Quarter,OrderDate)=4 and SalesPersonID is not null
Group by SalesPersonID
Order by SUM(SubTotal)

Select
	MaNV,
	TongDT,
	ROW_NUMBER() Over (Order by TongDT Desc) rnk
from #cte01

--Case 02: Thống kê xếp hạng doanh thu theo mã nhân viên và khu vực tại thời điểm quý 4 năm 2013
Select 
	SalesPersonID MaNV,
	TerritoryID Ma_KV,
	SUM(SubTotal) TongDT
	INTO #bang01

From Sales.SalesOrderHeader
Where YEAR(OrderDate)=2013 and DATEPART(Quarter,OrderDate)=4 and SalesPersonID is not null
Group by SalesPersonID, TerritoryID
Order by SalesPersonID, TerritoryID

Select *,
	ROW_NUMBER() Over(Partition by MaNV order by TongDT Desc) Rnk
From #bang01

-- Case 03: Thống kê các nhân viên có bán sản phẩm trong top 10 sản phẩm có doanh thu cao nhất, doanh thu của các sản phẩm đó và xếp hạng trong năm 2013
--Sales.SalesOrderHeader: hóa đơn
--Sales.SalesOrderDetail: chi tiết hóa đơn

Select Top 10
	b.ProductID Ma_SP,
	SUM(b.LineTotal) Doanhthu
	INTO #bangtamtop10
From Sales.SalesOrderHeader a inner join Sales.SalesOrderDetail b on a.SalesOrderID=b.SalesOrderID
Where YEAR(a.OrderDate)=2013
Group by b.ProductID
Order by SUM(b.LineTotal) DESC

Select 
	e.SalesPersonID MaNV,
	f.ProductID Ma_SP,
	SUM(f.LineTotal) Tong_DT
from Sales.SalesOrderHeader e inner join Sales.SalesOrderDetail f on e.SalesOrderID=f.SalesOrderID 
	 inner join #bangtamtop10 g on f.ProductID=g.Ma_SP

Where YEAR(e.OrderDate)=2013 and e.SalesPersonID is not null
Group by e.SalesPersonID, f.ProductID
order by e.SalesPersonID,f.ProductID

--Case 04: Thống kê những sản phẩm thuộc top 10 sản phẩm có doanh thu cao nhất và chọn top 3 sản phẩm bán tốt nhất của mỗi nhân viên

Select 
	a.SalesPersonID Ma_NV,
	b.ProductID Ma_sp,
	SUM(b.LineTotal) Tong_DT,
	Rank()over(Partition by a.SalesPersonID order by sum(b.LineTotal) desc) rnk
INTO #bangtop03
From Sales.SalesOrderHeader a inner join Sales.SalesOrderDetail b on a.SalesOrderID=b.SalesOrderID
where YEAR(a.OrderDate)=2013 and a.SalesPersonID is not null and b.ProductID in (select ProductID from #bangtamtop10)
group by a.SalesPersonID, b.ProductID
Order by a.SalesPersonID,rnk

Select *
From #bangtop03
where rnk<=3