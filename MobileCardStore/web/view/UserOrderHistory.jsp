<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lịch sử đơn hàng<c:if test="${not empty user}"> - ${user.fullName != null ? user.fullName : user.username}</c:if> - Mobile Card Store</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                background-color: #f5f7fa;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                color: #333;
            }
            
            /* Page Header */
            .page-header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 12px;
                padding: 40px;
                margin-bottom: 30px;
                box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
                color: white;
            }
            
            .user-info {
                display: flex;
                align-items: center;
                gap: 25px;
                margin-bottom: 30px;
            }
            
            .user-avatar {
                width: 100px;
                height: 100px;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.2);
                backdrop-filter: blur(10px);
                border: 3px solid rgba(255, 255, 255, 0.3);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 700;
                font-size: 2.5rem;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            }
            
            .user-details h2 {
                margin: 0 0 10px 0;
                color: white;
                font-weight: 700;
                font-size: 2rem;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            
            .user-details p {
                margin: 8px 0;
                color: rgba(255, 255, 255, 0.9);
                font-size: 1rem;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .user-details i {
                font-size: 1.1rem;
            }
            
            /* Statistics Cards */
            .stats-row {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 20px;
                margin-top: 30px;
            }
            
            .stat-item {
                text-align: center;
                padding: 25px 20px;
                background: rgba(255, 255, 255, 0.15);
                backdrop-filter: blur(10px);
                border-radius: 12px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                transition: all 0.3s ease;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }
            
            .stat-item:hover {
                transform: translateY(-5px);
                background: rgba(255, 255, 255, 0.25);
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            }
            
            .stat-value {
                font-size: 2rem;
                font-weight: 700;
                color: white;
                margin-bottom: 8px;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            
            .stat-label {
                font-size: 0.85rem;
                color: rgba(255, 255, 255, 0.9);
                text-transform: uppercase;
                font-weight: 500;
                letter-spacing: 1px;
            }
            
            /* Orders Card */
            .orders-card {
                background: white;
                border-radius: 12px;
                box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
                overflow: hidden;
                border: 1px solid #e9ecef;
            }
            
            .orders-card-header {
                padding: 25px 30px;
                background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
                border-bottom: 2px solid #dee2e6;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .orders-card-header h5 {
                margin: 0;
                font-weight: 600;
                color: #212529;
                display: flex;
                align-items: center;
                gap: 12px;
                font-size: 1.25rem;
            }
            
            .orders-card-header h5 i {
                color: #667eea;
                font-size: 1.5rem;
            }
            
            /* Table Styles */
            .data-table {
                width: 100%;
                border-collapse: collapse;
            }
            
            .data-table thead {
                background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            }
            
            .data-table th {
                padding: 18px 15px;
                text-align: left;
                font-weight: 600;
                color: #495057;
                border-bottom: 2px solid #dee2e6;
                font-size: 0.875rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .data-table td {
                padding: 18px 15px;
                border-bottom: 1px solid #f0f0f0;
                color: #495057;
                font-size: 0.95rem;
                vertical-align: middle;
            }
            
            .data-table tbody tr {
                transition: all 0.2s ease;
            }
            
            .data-table tbody tr:hover {
                background-color: #f8f9fa;
                transform: scale(1.01);
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            }
            
            .data-table tbody tr:last-child td {
                border-bottom: none;
            }
            
            /* Status Badges */
            .status-badge {
                padding: 8px 16px;
                border-radius: 25px;
                font-size: 0.8rem;
                font-weight: 600;
                display: inline-block;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            
            .status-pending {
                background: linear-gradient(135deg, #fff3cd 0%, #ffe69c 100%);
                color: #856404;
                border: 1px solid #ffc107;
            }
            
            .status-processing {
                background: linear-gradient(135deg, #cfe2ff 0%, #9ec5fe 100%);
                color: #084298;
                border: 1px solid #0d6efd;
            }
            
            .status-completed {
                background: linear-gradient(135deg, #d1e7dd 0%, #a3cfbb 100%);
                color: #0f5132;
                border: 1px solid #198754;
            }
            
            .status-failed {
                background: linear-gradient(135deg, #f8d7da 0%, #f1aeb5 100%);
                color: #842029;
                border: 1px solid #dc3545;
            }
            
            /* Order Info */
            .order-id {
                font-weight: 700;
                color: #667eea;
                font-size: 1rem;
            }
            
            .product-info {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }
            
            .product-name {
                font-weight: 600;
                color: #212529;
                font-size: 1rem;
            }
            
            .product-provider {
                font-size: 0.85rem;
                color: #6c757d;
                display: flex;
                align-items: center;
                gap: 5px;
            }
            
            .product-provider::before {
                content: "🏢";
                font-size: 0.9rem;
            }
            
            .price {
                font-weight: 700;
                color: #198754;
                font-size: 1.1rem;
            }
            
            /* Buttons */
            .btn {
                padding: 10px 20px;
                border: none;
                border-radius: 8px;
                font-weight: 500;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
                transition: all 0.3s ease;
                font-size: 0.9rem;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            
            .btn-primary {
                background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
                color: white;
            }
            
            .btn-primary:hover {
                background: linear-gradient(135deg, #0b5ed7 0%, #0a58ca 100%);
                color: white;
                text-decoration: none;
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(13, 110, 253, 0.3);
            }
            
            .btn-secondary {
                background: linear-gradient(135deg, #6c757d 0%, #5c636a 100%);
                color: white;
            }
            
            .btn-secondary:hover {
                background: linear-gradient(135deg, #5c636a 0%, #565e64 100%);
                color: white;
                text-decoration: none;
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(108, 117, 125, 0.3);
            }
            
            /* Empty State */
            .empty-state {
                text-align: center;
                padding: 80px 20px;
                color: #6c757d;
            }
            
            .empty-state i {
                font-size: 5rem;
                margin-bottom: 25px;
                opacity: 0.3;
                color: #adb5bd;
            }
            
            .empty-state h4 {
                margin-bottom: 15px;
                color: #495057;
                font-weight: 600;
                font-size: 1.5rem;
            }
            
            .empty-state p {
                margin-bottom: 30px;
                font-size: 1rem;
                color: #6c757d;
            }
            
            /* Date Display */
            .date-display {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }
            
            .date-main {
                font-weight: 500;
                color: #212529;
            }
            
            .date-time {
                font-size: 0.85rem;
                color: #6c757d;
            }
            
            /* Discount Badge */
            .discount-badge {
                display: inline-block;
                padding: 4px 8px;
                background: #fff3cd;
                color: #856404;
                border-radius: 4px;
                font-size: 0.8rem;
                margin-top: 4px;
            }
            
            /* Responsive Design */
            @media (max-width: 768px) {
                .page-header {
                    padding: 25px 20px;
                }
                
                .user-info {
                    flex-direction: column;
                    text-align: center;
                    gap: 15px;
                }
                
                .user-avatar {
                    width: 80px;
                    height: 80px;
                    font-size: 2rem;
                }
                
                .user-details h2 {
                    font-size: 1.5rem;
                }
                
                .stats-row {
                    grid-template-columns: repeat(2, 1fr);
                    gap: 15px;
                }
                
                .stat-item {
                    padding: 20px 15px;
                }
                
                .stat-value {
                    font-size: 1.5rem;
                }
                
                .orders-card-header {
                    flex-direction: column;
                    gap: 15px;
                    align-items: flex-start;
                }
                
                .data-table {
                    font-size: 0.85rem;
                    display: block;
                    overflow-x: auto;
                }
                
                .data-table th,
                .data-table td {
                    padding: 12px 10px;
                    white-space: nowrap;
                }
                
                .btn {
                    padding: 8px 15px;
                    font-size: 0.85rem;
                }
            }
            
            @media (max-width: 576px) {
                .stats-row {
                    grid-template-columns: 1fr;
                }
                
                .orders-card-header h5 {
                    font-size: 1.1rem;
                }
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container-fluid py-4">
            <!-- User Information Header -->
            <c:if test="${not empty user}">
                <div class="page-header">
                    <div class="user-info">
                        <div class="user-avatar">
                            ${user.fullName != null ? user.fullName.substring(0,1).toUpperCase() : user.username.substring(0,1).toUpperCase()}
                        </div>
                        <div class="user-details">
                            <h2>${user.fullName != null ? user.fullName : user.username}</h2>
                            <p><i class="bi bi-envelope"></i> ${user.email}</p>
                            <c:if test="${not empty user.phoneNumber}">
                                <p><i class="bi bi-telephone"></i> ${user.phoneNumber}</p>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- Order Statistics -->
                    <c:if test="${not empty orders}">
                        <c:set var="totalOrders" value="${orders.size()}" />
                        <c:set var="completedCount" value="0" />
                        <c:set var="processingCount" value="0" />
                        <c:set var="totalSpent" value="0" />
                        <c:forEach var="order" items="${orders}">
                            <c:if test="${order.status eq 'COMPLETED'}">
                                <c:set var="completedCount" value="${completedCount + 1}" />
                            </c:if>
                            <c:if test="${order.status eq 'PROCESSING'}">
                                <c:set var="processingCount" value="${processingCount + 1}" />
                            </c:if>
                            <c:set var="totalSpent" value="${totalSpent + order.totalAmount.doubleValue()}" />
                        </c:forEach>
                        
                        <div class="stats-row">
                            <div class="stat-item">
                                <div class="stat-value">${totalOrders}</div>
                                <div class="stat-label">Tổng đơn hàng</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${completedCount}</div>
                                <div class="stat-label">Hoàn thành</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">${processingCount}</div>
                                <div class="stat-label">Đang xử lý</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">
                                    <fmt:formatNumber value="${totalSpent}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                </div>
                                <div class="stat-label">Tổng chi tiêu</div>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:if>
            
            <!-- Orders List -->
            <div class="orders-card">
                <div class="orders-card-header">
                    <h5><i class="bi bi-clock-history"></i> Lịch sử đơn hàng</h5>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
                
                <c:choose>
                    <c:when test="${empty orders}">
                        <div class="empty-state">
                            <i class="bi bi-inbox"></i>
                            <h4>Chưa có đơn hàng nào</h4>
                            <p>Người dùng này chưa thực hiện đơn hàng nào.</p>
                           
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID Đơn hàng</th>
                                    <th>Sản phẩm</th>
                                    <th>Số lượng</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày đặt</th>
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
                                            <c:if test="${order.discountAmount != null and order.discountAmount > 0}">
                                                <span class="discount-badge">
                                                    <i class="bi bi-tag"></i> Giảm <fmt:formatNumber value="${order.discountAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                </span>
                                            </c:if>
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
                                            <div class="date-display">
                                                <span class="date-main">
                                                    <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy" />
                                                </span>
                                                <span class="date-time">
                                                    <fmt:formatDate value="${order.createdAt}" pattern="HH:mm" />
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/admin/orders/detail/${order.orderId}" 
                                               class="btn btn-primary" title="Xem chi tiết">
                                                <i class="bi bi-eye"></i> Chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>
