<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản lý đơn hàng - Mobile Card Store</title>
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
            
            
            /* Statistics Cards */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            
            .stat-card {
                background: white;
                border-radius: 8px;
                padding: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                transition: transform 0.2s, box-shadow 0.2s;
                border: 1px solid #e0e0e0;
                text-align: center;
            }
            
            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            }
            
            .stat-card-title {
                font-size: 0.9rem;
                color: #6c757d;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 10px;
            }
            
            .stat-card-value {
                font-size: 1.8rem;
                font-weight: 700;
                color: #212529;
                margin-bottom: 5px;
                line-height: 1.2;
            }
            
            /* Content Cards - matching ManageUsers */
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
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .content-card-body {
                padding: 20px;
            }
            
            /* Search Form - matching ManageUsers */
            .search-form {
                background-color: #f8f9fa;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .search-form .form-label {
                font-weight: 600;
                color: #495057;
                font-size: 0.9rem;
                margin-bottom: 8px;
            }
            .search-form .form-control,
            .search-form .form-select {
                border: 1px solid #ced4da;
                border-radius: 4px;
            }
            .search-form .form-control:focus,
            .search-form .form-select:focus {
                border-color: #0d6efd;
                box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
            }
            
            /* Price Filter Buttons */
            .price-filter-btn {
                border-radius: 20px;
                padding: 6px 16px;
                font-size: 0.85rem;
                font-weight: 500;
                transition: all 0.2s ease;
                border: 1px solid #ced4da;
                background: white;
                color: #495057;
            }
            
            .price-filter-btn:hover {
                background: #e7f1ff;
                border-color: #0d6efd;
                color: #0d6efd;
            }
            
            .price-filter-btn.active {
                background: #0d6efd;
                border-color: #0d6efd;
                color: white;
            }
            
            .price-filter-btn.clear-btn {
                color: #dc3545;
                border-color: #dc3545;
            }
            
            .price-filter-btn.clear-btn:hover {
                background: #f8d7da;
                border-color: #dc3545;
            }
            
            /* Manual Price Input */
            .manual-price-input {
                width: 120px;
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
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .content-card-body {
                padding: 0;
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
                padding: 15px 12px;
                text-align: left;
                font-weight: 600;
                color: #212529;
                border-bottom: 2px solid #dee2e6;
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .data-table td {
                padding: 15px 12px;
                border-bottom: 1px solid #e0e0e0;
                color: #495057;
                font-size: 0.95rem;
                vertical-align: middle;
            }
            
            .data-table tbody tr:hover {
                background-color: #f8f9fa;
            }
            
            /* Status Badges */
            .status-badge {
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 500;
                display: inline-block;
                text-transform: uppercase;
                letter-spacing: 0.5px;
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
            
            /* Action Buttons */
            .action-buttons {
                display: flex;
                gap: 5px;
            }
            
            .btn-action {
                padding: 6px 12px;
                border: none;
                border-radius: 4px;
                font-size: 0.85rem;
                cursor: pointer;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }
            
            .btn-view {
                background-color: #0d6efd;
                color: white;
            }
            
            .btn-view:hover {
                background-color: #0b5ed7;
                color: white;
                text-decoration: none;
            }
            
            .btn-edit {
                background-color: #198754;
                color: white;
            }
            
            .btn-edit:hover {
                background-color: #157347;
            }
            
            .btn-delete {
                background-color: #dc3545;
                color: white;
            }
            
            .btn-delete:hover {
                background-color: #bb2d3b;
            }
            
            /* Pagination */
            .pagination-wrapper {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px;
                background: white;
                border-top: 1px solid #e0e0e0;
            }
            
            .pagination-info {
                color: #6c757d;
                font-size: 0.9rem;
            }
            
            .pagination {
                display: flex;
                gap: 5px;
                list-style: none;
                margin: 0;
                padding: 0;
            }
            
            .page-item {
                border-radius: 4px;
                overflow: hidden;
            }
            
            .page-link {
                padding: 8px 12px;
                color: #6c757d;
                text-decoration: none;
                border: 1px solid #dee2e6;
                background-color: white;
                transition: all 0.3s;
            }
            
            .page-link:hover {
                background-color: #e9ecef;
                color: #495057;
                text-decoration: none;
            }
            
            .page-item.active .page-link {
                background-color: #ffc107;
                border-color: #ffc107;
                color: #000;
                font-weight: 600;
            }
            
            .page-item.disabled .page-link {
                color: #adb5bd;
                background-color: #f8f9fa;
                border-color: #dee2e6;
                cursor: not-allowed;
            }
            
            /* Alert Messages */
            .alert {
                padding: 15px 20px;
                margin-bottom: 20px;
                border: 1px solid transparent;
                border-radius: 4px;
                font-size: 0.95rem;
            }
            
            .alert-success {
                color: #0f5132;
                background-color: #d1e7dd;
                border-color: #badbcc;
            }
            
            .alert-danger {
                color: #842029;
                background-color: #f8d7da;
                border-color: #f5c2c7;
            }
            
            .alert-info {
                color: #055160;
                background-color: #cff4fc;
                border-color: #b8daff;
            }
            
            /* Responsive Design */
            @media (max-width: 768px) {
                .admin-container {
                    flex-direction: column;
                }
                
                .admin-sidebar {
                    width: 100%;
                }
                
                .filters-row {
                    flex-direction: column;
                }
                
                .filter-group {
                    min-width: 100%;
                }
                
                .data-table {
                    font-size: 0.85rem;
                }
                
                .data-table th,
                .data-table td {
                    padding: 10px 8px;
                }
            }
            
            /* User Link */
            .user-link {
                color: #0d6efd;
                text-decoration: none;
                font-weight: 500;
            }
            
            .user-link:hover {
                color: #0b5ed7;
                text-decoration: underline;
            }
            
            /* Order ID */
            .order-id {
                font-weight: 600;
                color: #495057;
            }
            
            /* Product Info */
            .product-info {
                display: flex;
                flex-direction: column;
                gap: 2px;
            }
            
            .product-name {
                font-weight: 500;
                color: #212529;
            }
            
            .product-provider {
                font-size: 0.85rem;
                color: #6c757d;
            }
            
            /* Price */
            .price {
                font-weight: 600;
                color: #198754;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-cart"></i> Quản lý đơn hàng</span>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-primary btn-sm">
                        <i class="bi bi-speedometer2"></i> Về Dashboard
                    </a>
                </div>
                
                <div class="content-card-body">
                
                <!-- Alert Messages -->
                <c:if test="${param.success eq 'status_updated'}">
                    <div class="alert alert-success">
                        <i class="bi bi-check-circle"></i> Cập nhật trạng thái đơn hàng thành công!
                    </div>
                </c:if>
                
                <c:if test="${param.success eq 'order_deleted'}">
                    <div class="alert alert-success">
                        <i class="bi bi-check-circle"></i> Xóa đơn hàng thành công!
                    </div>
                </c:if>
                
                <c:if test="${param.error ne null}">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle"></i>
                        <c:choose>
                            <c:when test="${param.error eq 'missing_params'}">Thiếu thông tin cần thiết!</c:when>
                            <c:when test="${param.error eq 'invalid_status'}">Trạng thái không hợp lệ!</c:when>
                            <c:when test="${param.error eq 'invalid_transition'}">
                                Không thể thay đổi trạng thái! 
                                <c:if test="${param.current eq 'COMPLETED' or param.current eq 'FAILED'}">
                                    Đơn hàng đã kết thúc, không thể thay đổi trạng thái.
                                </c:if>
                                <c:if test="${param.current eq 'PENDING'}">
                                    Đơn hàng đang chờ xử lý, chỉ có thể chuyển sang "Đang xử lý".
                                </c:if>
                                <c:if test="${param.current eq 'PROCESSING'}">
                                    Đơn hàng đang xử lý, chỉ có thể chuyển sang "Hoàn thành" hoặc "Thất bại".
                                </c:if>
                            </c:when>
                            <c:when test="${param.error eq 'order_not_found'}">Không tìm thấy đơn hàng!</c:when>
                            <c:when test="${param.error eq 'update_failed'}">Cập nhật thất bại!</c:when>
                            <c:when test="${param.error eq 'invalid_order_id'}">ID đơn hàng không hợp lệ!</c:when>
                            <c:when test="${param.error eq 'delete_failed'}">Xóa đơn hàng thất bại!</c:when>
                            <c:otherwise>Đã xảy ra lỗi không xác định!</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="bi bi-exclamation-triangle"></i> ${error}
                    </div>
                </c:if>
                
                <!-- Statistics Cards -->
                <c:if test="${not empty orderStats}">
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-card-title">Tổng đơn hàng</div>
                            <div class="stat-card-value">${totalOrders}</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-title">Chờ xử lý</div>
                            <div class="stat-card-value">${orderStats['PENDING'] != null ? orderStats['PENDING'] : 0}</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-title">Đang xử lý</div>
                            <div class="stat-card-value">${orderStats['PROCESSING'] != null ? orderStats['PROCESSING'] : 0}</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-title">Hoàn thành</div>
                            <div class="stat-card-value">${orderStats['COMPLETED'] != null ? orderStats['COMPLETED'] : 0}</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-card-title">Thất bại</div>
                            <div class="stat-card-value">${orderStats['FAILED'] != null ? orderStats['FAILED'] : 0}</div>
                        </div>
                    </div>
                </c:if>
                
                <!-- Search and Filter Section -->
                <div class="search-form mb-4">
                    <form method="GET" action="${pageContext.request.contextPath}/admin/orders" id="filterForm">
                        <!-- First Row: Search, Status, Provider, Sort -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Tìm kiếm</label>
                                <input type="text" class="form-control" name="search" id="searchInput" 
                                       value="${searchTerm}" 
                                       placeholder="ID, tên người dùng, email, sản phẩm..."
                                       maxlength="100"
                                       pattern="[a-zA-Z0-9@.\\s\\-+]*"
                                       title="Chỉ được nhập chữ cái, số, @, ., khoảng trắng, - và +">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Trạng thái</label>
                                <select class="form-select" name="status">
                                    <option value="">Tất cả</option>
                                    <option value="PENDING" ${statusFilter eq 'PENDING' ? 'selected' : ''}>Chờ xử lý</option>
                                    <option value="PROCESSING" ${statusFilter eq 'PROCESSING' ? 'selected' : ''}>Đang xử lý</option>
                                    <option value="COMPLETED" ${statusFilter eq 'COMPLETED' ? 'selected' : ''}>Hoàn thành</option>
                                    <option value="FAILED" ${statusFilter eq 'FAILED' ? 'selected' : ''}>Thất bại</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Nhà cung cấp</label>
                                <select class="form-select" name="provider">
                                    <option value="">Tất cả</option>
                                    <c:forEach var="provider" items="${providers}">
                                        <option value="${provider}" ${providerFilter eq provider ? 'selected' : ''}>${provider}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Sắp xếp theo</label>
                                <select class="form-select" name="sortBy">
                                    <option value="created_at" ${sortBy eq 'created_at' ? 'selected' : ''}>Ngày tạo</option>
                                    <option value="order_id" ${sortBy eq 'order_id' ? 'selected' : ''}>ID đơn hàng</option>
                                    <option value="product_name" ${sortBy eq 'product_name' ? 'selected' : ''}>Tên sản phẩm</option>
                                    <option value="total_amount" ${sortBy eq 'total_amount' ? 'selected' : ''}>Giá tiền</option>
                                    <option value="status" ${sortBy eq 'status' ? 'selected' : ''}>Trạng thái</option>
                                    <option value="username" ${sortBy eq 'username' ? 'selected' : ''}>Tên người dùng</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Thứ tự</label>
                                <select class="form-select" name="sortDir">
                                    <option value="DESC" ${sortDir eq 'DESC' ? 'selected' : ''}>Giảm dần</option>
                                    <option value="ASC" ${sortDir eq 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Second Row: Price Range Filter (like ViewProducts.jsp) -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-12">
                                <label class="form-label mb-2">Khoảng giá</label>
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <c:set var="isUnder50k" value="${(empty minPrice || minPrice == '0') && (empty maxPrice || maxPrice == '50000')}" />
                                    <button type="button" onclick="setPriceRange(0, 50000)" 
                                            class="price-filter-btn ${isUnder50k ? 'active' : ''}">
                                        < 50K
                                    </button>
                                    
                                    <c:set var="is50k100k" value="${minPrice == '50000' && maxPrice == '100000'}" />
                                    <button type="button" onclick="setPriceRange(50000, 100000)" 
                                            class="price-filter-btn ${is50k100k ? 'active' : ''}">
                                        50K-100K
                                    </button>
                                    
                                    <c:set var="is100k200k" value="${minPrice == '100000' && maxPrice == '200000'}" />
                                    <button type="button" onclick="setPriceRange(100000, 200000)" 
                                            class="price-filter-btn ${is100k200k ? 'active' : ''}">
                                        100K-200K
                                    </button>
                                    
                                    <c:set var="is200k500k" value="${minPrice == '200000' && maxPrice == '500000'}" />
                                    <button type="button" onclick="setPriceRange(200000, 500000)" 
                                            class="price-filter-btn ${is200k500k ? 'active' : ''}">
                                        200K-500K
                                    </button>
                                    
                                    <c:set var="isOver500k" value="${minPrice == '500000' && empty maxPrice}" />
                                    <button type="button" onclick="setPriceRange(500000, null)" 
                                            class="price-filter-btn ${isOver500k ? 'active' : ''}">
                                        > 500K
                                    </button>
                                    
                                    <button type="button" onclick="clearPriceRange()" 
                                            class="price-filter-btn clear-btn">
                                        × Xóa
                                    </button>
                                    
                                    <!-- Manual Price Input -->
                                    <div class="d-flex align-items-center gap-2 ms-3">
                                        <input type="number" class="form-control form-control-sm manual-price-input" 
                                               id="minPriceInput" 
                                               placeholder="Từ" 
                                               min="0" 
                                               step="1000">
                                        <span class="text-muted">-</span>
                                        <input type="number" class="form-control form-control-sm manual-price-input" 
                                               id="maxPriceInput" 
                                               placeholder="Đến" 
                                               min="0" 
                                               step="1000">
                                        <button type="button" onclick="applyManualPriceRange()" 
                                                class="btn btn-sm btn-outline-primary">
                                            Áp dụng
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Action Buttons Row -->
                        <div class="row g-3">
                            <div class="col-md-12 d-flex justify-content-end gap-2">
                                <button class="btn btn-primary" type="submit">
                                    <i class="bi bi-search"></i> Tìm kiếm
                                </button>
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/orders">
                                    <i class="bi bi-arrow-clockwise"></i> Reset
                                </a>
                            </div>
                        </div>
                        
                        <!-- Hidden inputs for price -->
                        <input type="hidden" name="minPrice" id="minPrice" value="${minPrice}">
                        <input type="hidden" name="maxPrice" id="maxPrice" value="${maxPrice}">
                        <input type="hidden" name="page" value="1" id="pageInput">
                    </form>
                </div>
                
                <!-- Orders Table -->
                <div class="content-card">
                    <div class="content-card-header">
                        Danh sách đơn hàng
                        <span class="badge bg-secondary">${totalOrders} đơn hàng</span>
                    </div>
                    <div class="content-card-body">
                        <c:choose>
                            <c:when test="${empty orders}">
                                <div class="text-center py-5">
                                    <i class="bi bi-inbox" style="font-size: 3rem; color: #adb5bd;"></i>
                                    <p class="text-muted mt-3">Không có đơn hàng nào được tìm thấy.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="data-table">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Khách hàng</th>
                                            <th>Sản phẩm</th>
                                            <th>Số lượng</th>
                                            <th>Tổng tiền</th>
                                            <th>Trạng thái</th>
                                            <th>Ngày tạo</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="order" items="${orders}">
                                            <tr>
                                                <td>
                                                    <span class="order-id">#${order.orderId}</span>
                                                </td>
                                                <td>
                                                    <c:if test="${not empty order.user}">
                                                        <a href="${pageContext.request.contextPath}/admin/orders/history/${order.user.userId}" class="user-link">
                                                            ${order.user.fullName != null ? order.user.fullName : order.user.username}
                                                        </a>
                                                        <br>
                                                        <small class="text-muted">${order.user.email}</small>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <div class="product-info">
                                                        <div class="product-name">${order.productName}</div>
                                                        <div class="product-provider">${order.providerName}</div>
                                                    </div>
                                                </td>
                                                <td>${order.quantity}</td>
                                                <td>
                                                    <span class="price">
                                                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">
                                                            <span class="status-badge status-pending">Chờ xử lý</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'PROCESSING'}">
                                                            <span class="status-badge status-processing">Đang xử lý</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'COMPLETED'}">
                                                            <span class="status-badge status-completed">Hoàn thành</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'FAILED'}">
                                                            <span class="status-badge status-failed">Thất bại</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <a href="${pageContext.request.contextPath}/admin/orders/detail/${order.orderId}" 
                                                           class="btn-action btn-view" title="Xem chi tiết">
                                                            <i class="bi bi-eye"></i>
                                                        </a>
                                                        
                                                        <!-- Quick Status Update - Only show valid transitions -->
                                                        <c:if test="${order.status ne 'COMPLETED' and order.status ne 'FAILED'}">
                                                            <div class="dropdown">
                                                                <button class="btn-action btn-edit dropdown-toggle" type="button" 
                                                                        data-bs-toggle="dropdown" title="Cập nhật trạng thái">
                                                                    <i class="bi bi-gear"></i>
                                                                </button>
                                                                <ul class="dropdown-menu">
                                                                    <!-- PENDING can only go to PROCESSING -->
                                                                    <c:if test="${order.status eq 'PENDING'}">
                                                                        <li>
                                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                                                <input type="hidden" name="action" value="updateStatus">
                                                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                                                <input type="hidden" name="status" value="PROCESSING">
                                                                                <button type="submit" class="dropdown-item">
                                                                                    <i class="bi bi-play-circle"></i> Bắt đầu xử lý
                                                                                </button>
                                                                            </form>
                                                                        </li>
                                                                    </c:if>
                                                                    
                                                                    <!-- PROCESSING can go to COMPLETED or FAILED -->
                                                                    <c:if test="${order.status eq 'PROCESSING'}">
                                                                        <li>
                                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                                                <input type="hidden" name="action" value="updateStatus">
                                                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                                                <input type="hidden" name="status" value="COMPLETED">
                                                                                <button type="submit" class="dropdown-item">
                                                                                    <i class="bi bi-check-circle"></i> Hoàn thành
                                                                                </button>
                                                                            </form>
                                                                        </li>
                                                                        <li>
                                                                            <form method="POST" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                                                <input type="hidden" name="action" value="updateStatus">
                                                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                                                <input type="hidden" name="status" value="FAILED">
                                                                                <button type="submit" class="dropdown-item text-danger" 
                                                                                        onclick="return confirm('Bạn có chắc chắn muốn đánh dấu đơn hàng này là thất bại?')">
                                                                                    <i class="bi bi-x-circle"></i> Đánh dấu thất bại
                                                                                </button>
                                                                            </form>
                                                                        </li>
                                                                    </c:if>
                                                                </ul>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${order.status eq 'COMPLETED' or order.status eq 'FAILED'}">
                                                            <span class="text-muted small" title="Đơn hàng đã kết thúc, không thể thay đổi trạng thái">
                                                                <i class="bi bi-lock"></i>
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                        
                        <!-- Pagination -->
                        <c:if test="${totalPages > 1}">
                            <div class="pagination-wrapper">
                                <div class="pagination-info">
                                    Hiển thị ${((currentPage - 1) * pageSize) + 1} - 
                                    ${currentPage * pageSize > totalOrders ? totalOrders : currentPage * pageSize} 
                                    trong ${totalOrders} đơn hàng
                                </div>
                                
                                <nav>
                                    <ul class="pagination">
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <a class="page-link page-btn" href="javascript:void(0)" data-page="${currentPage - 1}">Trước</a>
                                        </li>
                                        <c:forEach var="i" begin="1" end="${totalPages}">
                                            <c:if test="${i <= 3 || i > totalPages - 3 || (i >= currentPage - 1 && i <= currentPage + 1)}">
                                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                    <a class="page-link page-btn" href="javascript:void(0)" data-page="${i}">${i}</a>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <a class="page-link page-btn" href="javascript:void(0)" data-page="${currentPage + 1}">Sau</a>
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            var totalPages = <c:out value="${totalPages != null ? totalPages : 1}" />;
            function goToPage(page) {
                if (page < 1 || page > totalPages) return;
                document.getElementById('pageInput').value = page;
                document.getElementById('filterForm').submit();
            }
            
            // Price range functions
            function setPriceRange(min, max) {
                document.getElementById('minPrice').value = min || '';
                document.getElementById('maxPrice').value = max || '';
                // Update manual inputs
                var minPriceInput = document.getElementById('minPriceInput');
                var maxPriceInput = document.getElementById('maxPriceInput');
                if (minPriceInput) minPriceInput.value = min || '';
                if (maxPriceInput) maxPriceInput.value = max || '';
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            }
            
            function clearPriceRange() {
                document.getElementById('minPrice').value = '';
                document.getElementById('maxPrice').value = '';
                var minPriceInput = document.getElementById('minPriceInput');
                var maxPriceInput = document.getElementById('maxPriceInput');
                if (minPriceInput) minPriceInput.value = '';
                if (maxPriceInput) maxPriceInput.value = '';
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            }
            
            function applyManualPriceRange() {
                var min = document.getElementById('minPriceInput').value;
                var max = document.getElementById('maxPriceInput').value;
                
                if ((min && isNaN(min)) || (max && isNaN(max))) {
                    alert('Vui lòng nhập số hợp lệ');
                    return;
                }
                
                if (min && max && parseFloat(min) > parseFloat(max)) {
                    alert('Giá tối thiểu không được lớn hơn giá tối đa');
                    return;
                }
                
                document.getElementById('minPrice').value = min || '';
                document.getElementById('maxPrice').value = max || '';
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            }
            
            // Initialize manual price inputs with current values
            document.addEventListener('DOMContentLoaded', function() {
                var minPriceHidden = document.getElementById('minPrice');
                var maxPriceHidden = document.getElementById('maxPrice');
                var minPriceInput = document.getElementById('minPriceInput');
                var maxPriceInput = document.getElementById('maxPriceInput');
                
                if (minPriceHidden && minPriceInput && minPriceHidden.value) {
                    minPriceInput.value = minPriceHidden.value;
                }
                if (maxPriceHidden && maxPriceInput && maxPriceHidden.value) {
                    maxPriceInput.value = maxPriceHidden.value;
                }
            });
            
            // Handle pagination clicks
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelectorAll('.page-btn').forEach(function(btn) {
                    btn.addEventListener('click', function(e) {
                        e.preventDefault();
                        const page = parseInt(this.getAttribute('data-page'));
                        if (!isNaN(page)) {
                            goToPage(page);
                        }
                    });
                });
                
                // Search input validation - automatically remove _ and % characters
                var searchInput = document.getElementById('searchInput');
                
                if (searchInput) {
                    // Real-time validation on input - silently remove invalid characters
                    searchInput.addEventListener('input', function() {
                        var value = this.value;
                        // Remove invalid characters (_ and %) as user types
                        var cleaned = value.replace(/[_\u0025]/g, '');
                        if (value !== cleaned) {
                            this.value = cleaned;
                        }
                    });
                    
                    // Validate on form submit
                    document.getElementById('filterForm').addEventListener('submit', function(event) {
                        var value = searchInput.value.trim();
                        
                        // Remove any invalid characters before submit
                        var cleaned = value.replace(/[_\u0025]/g, '');
                        if (value !== cleaned) {
                            searchInput.value = cleaned;
                        }
                        
                        // Check if it's only spaces
                        if (searchInput.value.length > 0 && searchInput.value.replace(/\s+/g, '').length === 0) {
                            searchInput.value = '';
                        }
                    }, false);
                }
            });
        </script>
    </body>
</html>

