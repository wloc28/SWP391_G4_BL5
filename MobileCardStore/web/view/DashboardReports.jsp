<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Reports - Admin Dashboard</title>
        <%@include file="../components/libs.jsp" %>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background-color: #f5f5f5;
                color: #333;
            }
            
            /* Admin Header */
            .admin-header {
                background-color: #343a40;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            
            .admin-header-left {
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .admin-header-left i {
                font-size: 1.5rem;
            }
            
            .admin-header-right {
                display: flex;
                gap: 20px;
                align-items: center;
            }
            
            .admin-header-right a {
                color: white;
                text-decoration: none;
                padding: 8px 15px;
                transition: all 0.3s;
                border-radius: 4px;
                font-weight: 500;
            }
            
            .admin-header-right a:hover {
                background-color: rgba(255,255,255,0.1);
            }
            
            .admin-header-right a.btn-yellow {
                background-color: #ffc107;
                color: #000;
                font-weight: 600;
            }
            
            .admin-header-right a.btn-yellow:hover {
                background-color: #ffb300;
            }
            
            /* Breadcrumbs */
            .breadcrumbs {
                background-color: white;
                padding: 15px 30px;
                border-bottom: 1px solid #e0e0e0;
            }
            
            .breadcrumbs a {
                color: #6c757d;
                text-decoration: none;
                font-weight: 400;
            }
            
            .breadcrumbs a:hover {
                color: #212529;
            }
            
            .breadcrumbs span {
                color: #adb5bd;
                margin: 0 8px;
                font-weight: 400;
            }
            
            /* Main Container */
            .admin-container {
                display: flex;
                min-height: calc(100vh - 100px);
            }
            
            /* Sidebar */
            .admin-sidebar {
                width: 250px;
                background-color: white;
                border-right: 1px solid #e0e0e0;
                padding: 20px 0;
            }
            
            .sidebar-menu {
                list-style: none;
            }
            
            .sidebar-menu-item {
                padding: 12px 20px;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            
            .sidebar-menu-item:hover {
                background-color: #f5f5f5;
            }
            
            .sidebar-menu-item.active {
                background-color: #fffbf0;
                border-left: 4px solid #ffc107;
            }
            
            .sidebar-menu-item a {
                color: #6c757d;
                text-decoration: none;
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 500;
            }
            
            .sidebar-menu-item.active a {
                color: #ffc107;
                font-weight: 600;
            }
            
            /* Main Content */
            .admin-content {
                flex: 1;
                padding: 30px;
                background-color: #f8f9fa;
            }
            
            .page-header {
                margin-bottom: 30px;
            }
            
            .page-header h1 {
                font-size: 2rem;
                font-weight: 700;
                color: #212529;
                margin-bottom: 10px;
            }
            
            .page-header p {
                color: #6c757d;
                font-size: 1rem;
            }
            
            /* Statistics Cards */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            
            .stat-card {
                background: white;
                border-radius: 8px;
                padding: 25px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                transition: transform 0.2s, box-shadow 0.2s;
                border: 1px solid #e0e0e0;
            }
            
            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            }
            
            .stat-card-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 15px;
            }
            
            .stat-card-title {
                font-size: 0.9rem;
                color: #6c757d;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .stat-card-icon {
                width: 48px;
                height: 48px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
            }
            
            .stat-card-icon.blue {
                background-color: #e3f2fd;
                color: #2196f3;
            }
            
            .stat-card-icon.green {
                background-color: #e8f5e9;
                color: #4caf50;
            }
            
            .stat-card-icon.orange {
                background-color: #fff3e0;
                color: #ff9800;
            }
            
            .stat-card-icon.purple {
                background-color: #f3e5f5;
                color: #9c27b0;
            }
            
            .stat-card-value {
                font-size: 2rem;
                font-weight: 700;
                color: #212529;
                margin-bottom: 5px;
            }
            
            .stat-card-change {
                font-size: 0.85rem;
                color: #6c757d;
            }
            
            /* Charts Section */
            .charts-section {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
                gap: 30px;
                margin-bottom: 30px;
            }
            
            .chart-card {
                background: white;
                border-radius: 8px;
                padding: 25px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                border: 1px solid #e0e0e0;
            }
            
            .chart-card-header {
                margin-bottom: 20px;
            }
            
            .chart-card-title {
                font-size: 1.25rem;
                font-weight: 600;
                color: #212529;
                margin-bottom: 5px;
            }
            
            .chart-card-subtitle {
                font-size: 0.9rem;
                color: #6c757d;
            }
            
            .chart-container {
                position: relative;
                height: 300px;
            }
            
            /* Tables Section */
            .tables-section {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
                gap: 30px;
                margin-bottom: 30px;
            }
            
            .table-card {
                background: white;
                border-radius: 8px;
                padding: 25px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                border: 1px solid #e0e0e0;
            }
            
            .table-card-header {
                margin-bottom: 20px;
            }
            
            .table-card-title {
                font-size: 1.25rem;
                font-weight: 600;
                color: #212529;
            }
            
            .table-responsive {
                overflow-x: auto;
            }
            
            table {
                width: 100%;
                border-collapse: collapse;
            }
            
            thead {
                background-color: #f8f9fa;
            }
            
            th {
                padding: 12px;
                text-align: left;
                font-weight: 600;
                color: #495057;
                border-bottom: 2px solid #dee2e6;
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            td {
                padding: 12px;
                border-bottom: 1px solid #dee2e6;
                color: #212529;
            }
            
            tbody tr:hover {
                background-color: #f8f9fa;
            }
            
            .badge {
                display: inline-block;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
            }
            
            .badge-success {
                background-color: #d4edda;
                color: #155724;
            }
            
            .badge-warning {
                background-color: #fff3cd;
                color: #856404;
            }
            
            .badge-danger {
                background-color: #f8d7da;
                color: #721c24;
            }
            
            .badge-info {
                background-color: #d1ecf1;
                color: #0c5460;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <!-- Breadcrumbs -->
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/admin/dashboard">Trang chủ</a>
            <span>></span>
            <span style="color: #333; font-weight: 500;">Reports</span>
        </div>
        
        <!-- Main Container -->
        <div class="admin-container">
            <!-- Sidebar -->
            <div class="admin-sidebar">
                <ul class="sidebar-menu">
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/admin/dashboard">
                            <i class="bi bi-speedometer2"></i>
                            <span>Trang chủ Admin</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item active">
                        <a href="${pageContext.request.contextPath}/admin/reports">
                            <i class="bi bi-graph-up"></i>
                            <span>Reports</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/admin/users">
                            <i class="bi bi-people"></i>
                            <span>Quản lý người dùng</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/plist">
                            <i class="bi bi-box"></i>
                            <span>Quản lý sản phẩm</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/pklist">
                            <i class="bi bi-archive"></i>
                            <span>Quản lý kho hàng</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/vlist">
                            <i class="bi bi-ticket-perforated"></i>
                            <span>Quản lý Voucher</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/admin/orders">
                            <i class="bi bi-cart"></i>
                            <span>Quản lý đơn hàng</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/provider-import">
                            <i class="bi bi-cart"></i>
                            <span>Nhập hàng</span>
                        </a>
                    </li>
                    <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/admin/feedback">
                            <i class="bi bi-chat-left-text"></i>
                            <span>Quản lý phản hồi</span>
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Main Content -->
            <div class="admin-content">
            <div class="page-header">
                <h1><i class="bi bi-graph-up"></i> Báo Cáo & Thống Kê</h1>
                <p>Xem tổng quan và phân tích chi tiết về hoạt động của hệ thống</p>
            </div>
            
            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card-header">
                        <span class="stat-card-title">Tổng Doanh Thu</span>
                        <div class="stat-card-icon green">
                            <i class="bi bi-currency-dollar"></i>
                        </div>
                    </div>
                    <div class="stat-card-value">
                        <fmt:formatNumber value="${totalRevenue}" type="currency" currencyCode="VND" pattern="#,##0" /> đ
                    </div>
                    <div class="stat-card-change">Tất cả đơn hàng đã hoàn thành</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <span class="stat-card-title">Doanh Thu Tháng Này</span>
                        <div class="stat-card-icon blue">
                            <i class="bi bi-calendar-month"></i>
                        </div>
                    </div>
                    <div class="stat-card-value">
                        <fmt:formatNumber value="${monthlyRevenue}" type="currency" currencyCode="VND" pattern="#,##0" /> đ
                    </div>
                    <div class="stat-card-change">Tháng hiện tại</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <span class="stat-card-title">Tổng Đơn Hàng</span>
                        <div class="stat-card-icon orange">
                            <i class="bi bi-cart-check"></i>
                        </div>
                    </div>
                    <div class="stat-card-value">${totalOrders}</div>
                    <div class="stat-card-change">Tất cả đơn hàng</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <span class="stat-card-title">Tổng Người Dùng</span>
                        <div class="stat-card-icon purple">
                            <i class="bi bi-people"></i>
                        </div>
                    </div>
                    <div class="stat-card-value">${totalUsers}</div>
                    <div class="stat-card-change">Khách hàng đã đăng ký</div>
                </div>
            </div>
            
            <!-- Charts Section -->
            <div class="charts-section">
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div class="chart-card-title">Doanh Thu Theo Tháng</div>
                        <div class="chart-card-subtitle">12 tháng gần nhất</div>
                    </div>
                    <div class="chart-container">
                        <canvas id="revenueByMonthChart"></canvas>
                    </div>
                </div>
                
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div class="chart-card-title">Doanh Thu Theo Ngày</div>
                        <div class="chart-card-subtitle">30 ngày gần nhất</div>
                    </div>
                    <div class="chart-container">
                        <canvas id="revenueByDayChart"></canvas>
                    </div>
                </div>
                
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div class="chart-card-title">Đơn Hàng Theo Tháng</div>
                        <div class="chart-card-subtitle">12 tháng gần nhất</div>
                    </div>
                    <div class="chart-container">
                        <canvas id="ordersByMonthChart"></canvas>
                    </div>
                </div>
                
                <div class="chart-card">
                    <div class="chart-card-header">
                        <div class="chart-card-title">Người Dùng Mới Theo Tháng</div>
                        <div class="chart-card-subtitle">12 tháng gần nhất</div>
                    </div>
                    <div class="chart-container">
                        <canvas id="newUsersByMonthChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Tables Section -->
            <div class="tables-section">
                <div class="table-card">
                    <div class="table-card-header">
                        <div class="table-card-title">Top Sản Phẩm Bán Chạy</div>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Sản Phẩm</th>
                                    <th>Nhà Cung Cấp</th>
                                    <th>Số Lượng Bán</th>
                                    <th>Số Đơn</th>
                                    <th>Doanh Thu</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="product" items="${topProducts}" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td>${product.productName}</td>
                                        <td>${product.providerName}</td>
                                        <td>${product.totalQuantity}</td>
                                        <td>${product.orderCount}</td>
                                        <td><fmt:formatNumber value="${product.totalRevenue}" type="currency" currencyCode="VND" pattern="#,##0" /> đ</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty topProducts}">
                                    <tr>
                                        <td colspan="6" style="text-align: center; color: #6c757d;">Chưa có dữ liệu</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div class="table-card">
                    <div class="table-card-header">
                        <div class="table-card-title">Top Khách Hàng</div>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Khách Hàng</th>
                                    <th>Email</th>
                                    <th>Số Đơn</th>
                                    <th>Tổng Chi Tiêu</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="customer" items="${topCustomers}" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td>${customer.fullName != null ? customer.fullName : customer.username}</td>
                                        <td>${customer.email}</td>
                                        <td>${customer.totalOrders}</td>
                                        <td><fmt:formatNumber value="${customer.totalSpent}" type="currency" currencyCode="VND" pattern="#,##0" /> đ</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty topCustomers}">
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: #6c757d;">Chưa có dữ liệu</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
          </div>
        </div>
        
        <script>
            // Revenue by Month Chart
            const revenueByMonthData = {
                labels: [<c:forEach var="entry" items="${revenueByMonth}">"${entry.key}",</c:forEach>].reverse(),
                datasets: [{
                    label: 'Doanh Thu (VNĐ)',
                    data: [<c:forEach var="entry" items="${revenueByMonth}">${entry.value},</c:forEach>].reverse(),
                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    borderColor: 'rgba(54, 162, 235, 1)',
                    borderWidth: 2,
                    tension: 0.4
                }]
            };
            
            new Chart(document.getElementById('revenueByMonthChart'), {
                type: 'line',
                data: revenueByMonthData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return new Intl.NumberFormat('vi-VN').format(value) + ' đ';
                                }
                            }
                        }
                    }
                }
            });
            
            // Revenue by Day Chart
            const revenueByDayData = {
                labels: [<c:forEach var="entry" items="${revenueByDay}">"${entry.key}",</c:forEach>].reverse(),
                datasets: [{
                    label: 'Doanh Thu (VNĐ)',
                    data: [<c:forEach var="entry" items="${revenueByDay}">${entry.value},</c:forEach>].reverse(),
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 2,
                    tension: 0.4
                }]
            };
            
            new Chart(document.getElementById('revenueByDayChart'), {
                type: 'line',
                data: revenueByDayData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function(value) {
                                    return new Intl.NumberFormat('vi-VN').format(value) + ' đ';
                                }
                            }
                        }
                    }
                }
            });
            
            // Orders by Month Chart
            const ordersByMonthData = {
                labels: [<c:forEach var="entry" items="${ordersByMonth}">"${entry.key}",</c:forEach>].reverse(),
                datasets: [{
                    label: 'Số Đơn Hàng',
                    data: [<c:forEach var="entry" items="${ordersByMonth}">${entry.value},</c:forEach>].reverse(),
                    backgroundColor: 'rgba(255, 159, 64, 0.2)',
                    borderColor: 'rgba(255, 159, 64, 1)',
                    borderWidth: 2,
                    tension: 0.4
                }]
            };
            
            new Chart(document.getElementById('ordersByMonthChart'), {
                type: 'line',
                data: ordersByMonthData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // New Users by Month Chart
            const newUsersByMonthData = {
                labels: [<c:forEach var="entry" items="${newUsersByMonth}">"${entry.key}",</c:forEach>].reverse(),
                datasets: [{
                    label: 'Người Dùng Mới',
                    data: [<c:forEach var="entry" items="${newUsersByMonth}">${entry.value},</c:forEach>].reverse(),
                    backgroundColor: 'rgba(153, 102, 255, 0.2)',
                    borderColor: 'rgba(153, 102, 255, 1)',
                    borderWidth: 2,
                    tension: 0.4
                }]
            };
            
            new Chart(document.getElementById('newUsersByMonthChart'), {
                type: 'line',
                data: newUsersByMonthData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // Orders by Status Chart
            const ordersByStatusData = {
                labels: [<c:forEach var="entry" items="${ordersByStatus}">"${entry.key}",</c:forEach>],
                datasets: [{
                    label: 'Số Đơn Hàng',
                    data: [<c:forEach var="entry" items="${ordersByStatus}">${entry.value},</c:forEach>],
                    backgroundColor: [
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(75, 192, 192, 0.2)',
                        'rgba(255, 206, 86, 0.2)',
                        'rgba(255, 99, 132, 0.2)',
                        'rgba(153, 102, 255, 0.2)'
                    ],
                    borderColor: [
                        'rgba(54, 162, 235, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(255, 99, 132, 1)',
                        'rgba(153, 102, 255, 1)'
                    ],
                    borderWidth: 2
                }]
            };
            
            new Chart(document.getElementById('ordersByStatusChart'), {
                type: 'doughnut',
                data: ordersByStatusData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: true,
                            position: 'right'
                        }
                    }
                }
            });
        </script>
    </body>
</html>
