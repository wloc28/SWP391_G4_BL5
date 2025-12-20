<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Admin Dashboard - Mobile Card Store</title>
        <%@include file="../components/libs.jsp" %>
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
            
            .user-info {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-right: 20px;
            }
            
            .user-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                object-fit: cover;
                border: 2px solid rgba(255,255,255,0.3);
            }
            
            .user-name {
                color: white;
                font-weight: 500;
                font-size: 0.95rem;
            }
            
            .user-dropdown {
                position: relative;
            }
            
            .user-dropdown-menu {
                display: none;
                position: absolute;
                top: 100%;
                right: 0;
                margin-top: 10px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                min-width: 200px;
                z-index: 1000;
            }
            
            .user-dropdown:hover .user-dropdown-menu {
                display: block;
            }
            
            .user-dropdown-item {
                padding: 12px 20px;
                color: #333;
                text-decoration: none;
                display: block;
                transition: background-color 0.2s;
            }
            
            .user-dropdown-item:hover {
                background-color: #f8f9fa;
                text-decoration: none;
                color: #333;
            }
            
            .user-dropdown-item:first-child {
                border-top-left-radius: 8px;
                border-top-right-radius: 8px;
            }
            
            .user-dropdown-item:last-child {
                border-bottom-left-radius: 8px;
                border-bottom-right-radius: 8px;
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
                padding: 12px 30px;
                cursor: pointer;
                transition: background-color 0.3s;
                border-left: 3px solid transparent;
                font-size: 0.95rem;
            }
            
            .sidebar-menu-item:hover {
                background-color: #f8f9fa;
            }
            
            .sidebar-menu-item.active {
                background-color: #fff5f5;
                border-left-color: #ffc107;
                color: #ffc107;
            }
            
            .sidebar-menu-item a {
                color: #212529;
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
            
            .sidebar-submenu {
                list-style: none;
                padding-left: 20px;
                max-height: 0;
                overflow: hidden;
                transition: max-height 0.3s ease;
            }
            
            .sidebar-submenu.show {
                max-height: 500px;
            }
            
            .sidebar-submenu-item {
                padding: 10px 30px;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            
            .sidebar-submenu-item:hover {
                background-color: #f5f5f5;
            }
            
            .sidebar-submenu-item.active {
                background-color: #fff5f5;
                color: #ffc107;
            }
            
            .sidebar-submenu-item a {
                color: #6c757d;
                text-decoration: none;
                font-weight: 400;
            }
            
            .sidebar-submenu-item.active a {
                color: #ffc107;
                font-weight: 600;
            }
            
            .menu-toggle {
                margin-left: auto;
                transition: transform 0.3s;
            }
            
            .menu-toggle.rotated {
                transform: rotate(90deg);
            }
            
            /* Main Content */
            .admin-content {
                flex: 1;
                padding: 30px;
                background-color: #f8f9fa;
            }
            
            .admin-content h2 {
                font-weight: 700;
                color: #212529;
                font-size: 1.75rem;
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
                font-size: 0.95rem;
                color: #6c757d;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .stat-card-icon {
                font-size: 2rem;
                opacity: 0.8;
            }
            
            .stat-card-value {
                font-size: 2.2rem;
                font-weight: 700;
                color: #212529;
                margin-bottom: 5px;
                line-height: 1.2;
            }
            
            .stat-card-footer {
                font-size: 0.875rem;
                color: #6c757d;
                font-weight: 400;
            }
            
            /* Content Cards */
            .content-card {
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            
            .content-card-header {
                padding: 20px;
                border-bottom: 1px solid #e0e0e0;
                font-weight: 600;
                color: #212529;
                font-size: 1.1rem;
            }
            
            .content-card-body {
                padding: 20px;
            }
            
            /* Table */
            .data-table {
                width: 100%;
                border-collapse: collapse;
            }
            
            .data-table thead {
                background-color: #f8f9fa;
            }
            
            .data-table th {
                padding: 12px;
                text-align: left;
                font-weight: 600;
                color: #212529;
                border-bottom: 2px solid #dee2e6;
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .data-table td {
                padding: 12px;
                border-bottom: 1px solid #e0e0e0;
                color: #495057;
                font-size: 0.95rem;
            }
            
            .data-table tbody tr:hover {
                background-color: #f8f9fa;
            }
            
            .status-badge {
                padding: 5px 12px;
                border-radius: 20px;
                font-size: 0.85rem;
                font-weight: 500;
                display: inline-block;
            }
            
            .status-pending {
                background-color: #fff3cd;
                color: #856404;
            }
            
            .status-processing {
                background-color: #cfe2ff;
                color: #084298;
            }
            
            .status-completed {
                background-color: #d1e7dd;
                color: #0f5132;
            }
            
            .status-failed {
                background-color: #f8d7da;
                color: #842029;
            }
            
            /* Quick Links Grid */
            .quick-links-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 15px;
            }
            
            .quick-link-item {
                background: white;
                border: 1px solid #e0e0e0;
                border-radius: 8px;
                padding: 20px;
                text-align: center;
                text-decoration: none;
                color: #333;
                transition: all 0.3s;
            }
            
            .quick-link-item:hover {
                border-color: #ffc107;
                background-color: #fffbf0;
                transform: translateY(-3px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                text-decoration: none;
                color: #ffc107;
            }
            
            .quick-link-icon {
                font-size: 2.5rem;
                margin-bottom: 10px;
                color: #343a40;
            }
            
            .quick-link-item:hover .quick-link-icon {
                color: #ffc107;
            }
            
            .quick-link-title {
                font-weight: 600;
                font-size: 0.95rem;
                color: #212529;
            }
            
            .quick-link-item:hover .quick-link-title {
                color: #ffc107;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <!-- Breadcrumbs -->
        <div class="breadcrumbs">
            <a href="dashboard">Trang chủ</a>
            <span>></span>
            <span style="color: #333; font-weight: 500;">Dashboard</span>
        </div>
        
        <!-- Main Container -->
        <div class="admin-container">
            <!-- Sidebar -->
            <div class="admin-sidebar">
                <ul class="sidebar-menu">
                    <li class="sidebar-menu-item active">
                        <a href="dashboard">
                            <i class="bi bi-speedometer2"></i>
                            <span>Trang chủ Admin</span>
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
                        <a href="${pageContext.request.contextPath}/admin/provider-import">
                            <i class="bi bi-cart"></i>
                            <span>Nhập hàng </span>
                     </li> 
                     <li class="sidebar-menu-item">
                        <a href="${pageContext.request.contextPath}/admin/transactions">
                            <i class="bi bi-cart"></i>
                            <span>Quản lý nạp tiền </span>
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
                <h2 style="margin-bottom: 25px; color: #333;">Tổng quan hệ thống</h2>
                
                <!-- Statistics Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <div class="stat-card-title">Tổng số người dùng</div>
                            <i class="bi bi-people-fill stat-card-icon" style="color: #667eea;"></i>
                        </div>
                        <div class="stat-card-value">
                            <fmt:formatNumber value="${totalUsers}" pattern="#,###" />
                        </div>
                        <div class="stat-card-footer">
                            <i class="bi bi-arrow-up"></i> ${newUsersThisMonth} người dùng mới trong tháng
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <div class="stat-card-title">Tổng số sản phẩm</div>
                            <i class="bi bi-box-seam stat-card-icon" style="color: #f5576c;"></i>
                        </div>
                        <div class="stat-card-value">
                            <fmt:formatNumber value="${totalProducts}" pattern="#,###" />
                        </div>
                        <div class="stat-card-footer">Sản phẩm đang hoạt động</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <div class="stat-card-title">Tổng số đơn hàng</div>
                            <i class="bi bi-cart-check stat-card-icon" style="color: #4facfe;"></i>
                        </div>
                        <div class="stat-card-value">
                            <fmt:formatNumber value="${totalOrders}" pattern="#,###" />
                        </div>
                        <div class="stat-card-footer">Tất cả đơn hàng</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <div class="stat-card-title">Tổng doanh thu</div>
                            <i class="bi bi-currency-dollar stat-card-icon" style="color: #43e97b;"></i>
                        </div>
                        <div class="stat-card-value">
                            <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                        </div>
                        <div class="stat-card-footer">
                            Tháng này: <fmt:formatNumber value="${monthlyRevenue}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <div class="stat-card-title">Tổng số Voucher</div>
                            <i class="bi bi-ticket-perforated stat-card-icon" style="color: #ff6b6b;"></i>
                        </div>
                        <div class="stat-card-value">
                            <fmt:formatNumber value="${totalVouchers}" pattern="#,###" />
                        </div>
                        <div class="stat-card-footer">
                            <c:choose>
                                <c:when test="${expiringSoonVouchers > 0}">
                                    <i class="bi bi-exclamation-triangle" style="color: #ffc107;"></i> ${activeVouchers} đang hoạt động, ${expiringSoonVouchers} sắp hết hạn
                                </c:when>
                                <c:otherwise>
                                    ${activeVouchers} voucher đang hoạt động
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            function toggleSubmenu(event, menuId) {
                event.preventDefault();
                const submenu = document.getElementById(menuId);
                const toggle = event.currentTarget.querySelector('.menu-toggle');
                
                if (submenu.classList.contains('show')) {
                    submenu.classList.remove('show');
                    toggle.classList.remove('rotated');
                } else {
                    // Đóng tất cả submenu khác
                    document.querySelectorAll('.sidebar-submenu').forEach(menu => {
                        if (menu.id !== menuId) {
                            menu.classList.remove('show');
                        }
                    });
                    document.querySelectorAll('.menu-toggle').forEach(t => {
                        if (t !== toggle) {
                            t.classList.remove('rotated');
                        }
                    });
                    
                    submenu.classList.add('show');
                    toggle.classList.add('rotated');
                }
            }
        </script>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>



