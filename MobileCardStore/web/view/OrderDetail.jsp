<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chi tiết đơn hàng #${order.orderId} - Mobile Card Store</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            body {
                background-color: #f8f9fa;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            }
            
            
            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }
            
            .page-title {
                font-size: 1.75rem;
                font-weight: 700;
                color: #212529;
                margin: 0;
            }
            
            .order-status {
                padding: 8px 16px;
                border-radius: 20px;
                font-size: 0.9rem;
                font-weight: 500;
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
            
            .detail-card {
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                border: 1px solid #e0e0e0;
                margin-bottom: 30px;
            }
            
            .detail-card-header {
                padding: 20px;
                border-bottom: 1px solid #e0e0e0;
                background-color: #f8f9fa;
                border-radius: 8px 8px 0 0;
            }
            
            .detail-card-header h5 {
                margin: 0;
                font-weight: 600;
                color: #212529;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            
            .detail-card-body {
                padding: 20px;
            }
            
            .info-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 12px 0;
                border-bottom: 1px solid #f0f0f0;
            }
            
            .info-row:last-child {
                border-bottom: none;
            }
            
            .info-label {
                font-weight: 500;
                color: #6c757d;
                min-width: 120px;
            }
            
            .info-value {
                color: #212529;
                font-weight: 500;
            }
            
            .user-info {
                display: flex;
                align-items: center;
                gap: 15px;
            }
            
            .user-avatar {
                width: 50px;
                height: 50px;
                border-radius: 50%;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 600;
                font-size: 1.2rem;
            }
            
            .user-details h6 {
                margin: 0;
                color: #212529;
                font-weight: 600;
            }
            
            .user-details p {
                margin: 0;
                color: #6c757d;
                font-size: 0.9rem;
            }
            
            .product-info {
                display: flex;
                align-items: center;
                gap: 15px;
            }
            
            .product-icon {
                width: 50px;
                height: 50px;
                border-radius: 8px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 1.2rem;
            }
            
            .product-details h6 {
                margin: 0;
                color: #212529;
                font-weight: 600;
            }
            
            .product-details p {
                margin: 0;
                color: #6c757d;
                font-size: 0.9rem;
            }
            
            .price-large {
                font-size: 1.5rem;
                font-weight: 700;
                color: #198754;
            }
            
            .timeline {
                position: relative;
                padding-left: 30px;
            }
            
            .timeline::before {
                content: '';
                position: absolute;
                left: 15px;
                top: 0;
                bottom: 0;
                width: 2px;
                background: #dee2e6;
            }
            
            .timeline-item {
                position: relative;
                margin-bottom: 20px;
            }
            
            .timeline-item::before {
                content: '';
                position: absolute;
                left: -25px;
                top: 5px;
                width: 10px;
                height: 10px;
                border-radius: 50%;
                background: #198754;
            }
            
            .timeline-item.active::before {
                background: #ffc107;
            }
            
            .timeline-content {
                background: #f8f9fa;
                padding: 15px;
                border-radius: 8px;
                border-left: 4px solid #198754;
            }
            
            .timeline-item.active .timeline-content {
                border-left-color: #ffc107;
                background: #fffbf0;
            }
            
            .timeline-title {
                font-weight: 600;
                color: #212529;
                margin-bottom: 5px;
            }
            
            .timeline-time {
                color: #6c757d;
                font-size: 0.9rem;
            }
            
            .action-buttons {
                display: flex;
                gap: 15px;
                flex-wrap: wrap;
            }
            
            .btn {
                padding: 10px 20px;
                border: none;
                border-radius: 6px;
                font-weight: 500;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
                transition: all 0.3s;
                font-size: 0.95rem;
            }
            
            .btn-primary {
                background-color: #0d6efd;
                color: white;
            }
            
            .btn-primary:hover {
                background-color: #0b5ed7;
                color: white;
                text-decoration: none;
            }
            
            .btn-success {
                background-color: #198754;
                color: white;
            }
            
            .btn-success:hover {
                background-color: #157347;
            }
            
            .btn-warning {
                background-color: #ffc107;
                color: #000;
            }
            
            .btn-warning:hover {
                background-color: #ffb300;
            }
            
            .btn-danger {
                background-color: #dc3545;
                color: white;
            }
            
            .btn-danger:hover {
                background-color: #bb2d3b;
            }
            
            .btn-secondary {
                background-color: #6c757d;
                color: white;
            }
            
            .btn-secondary:hover {
                background-color: #5c636a;
                color: white;
                text-decoration: none;
            }
            
            .alert {
                padding: 15px 20px;
                margin-bottom: 20px;
                border: 1px solid transparent;
                border-radius: 6px;
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
            
            .voucher-info {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 15px;
            }
            
            .voucher-code {
                font-weight: 600;
                font-size: 1.1rem;
                margin-bottom: 5px;
            }
            
            .voucher-discount {
                font-size: 0.9rem;
                opacity: 0.9;
            }
            
            .product-log {
                background: #f8f9fa;
                border: 1px solid #e9ecef;
                border-radius: 8px;
                padding: 15px;
            }
            
            .product-log-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px;
                background: white;
                border-radius: 6px;
                margin-bottom: 10px;
                border: 1px solid #e9ecef;
            }
            
            .product-log-item:last-child {
                margin-bottom: 0;
            }
            
            .log-label {
                font-weight: 500;
                color: #495057;
            }
            
            .log-value {
                font-weight: 600;
                color: #212529;
                font-family: monospace;
                background: #f1f3f4;
                padding: 2px 8px;
                border-radius: 4px;
            }
            
            @media (max-width: 768px) {
                .page-header {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 15px;
                }
                
                .info-row {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 5px;
                }
                
                .action-buttons {
                    flex-direction: column;
                }
                
                .btn {
                    justify-content: center;
                }
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container-fluid py-4">
            <!-- Alert Messages -->
            <c:if test="${param.success eq 'status_updated'}">
                <div class="alert alert-success">
                    <i class="bi bi-check-circle"></i> Cập nhật trạng thái đơn hàng thành công!
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
                        <c:otherwise>Đã xảy ra lỗi không xác định!</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="bi bi-exclamation-triangle"></i> ${error}
                </div>
            </c:if>
            
            <c:if test="${not empty order}">
                <!-- Page Header -->
                <div class="page-header">
                    <h1 class="page-title">Chi tiết đơn hàng #${order.orderId}</h1>
                    <c:choose>
                        <c:when test="${order.status eq 'PENDING'}">
                            <span class="order-status status-pending">Chờ xử lý</span>
                        </c:when>
                        <c:when test="${order.status eq 'PROCESSING'}">
                            <span class="order-status status-processing">Đang xử lý</span>
                        </c:when>
                        <c:when test="${order.status eq 'COMPLETED'}">
                            <span class="order-status status-completed">Hoàn thành</span>
                        </c:when>
                        <c:when test="${order.status eq 'FAILED'}">
                            <span class="order-status status-failed">Thất bại</span>
                        </c:when>
                    </c:choose>
                </div>
                
                <div class="row">
                    <div class="col-lg-8">
                        <!-- Order Information -->
                        <div class="detail-card">
                            <div class="detail-card-header">
                                <h5><i class="bi bi-info-circle"></i> Thông tin đơn hàng</h5>
                            </div>
                            <div class="detail-card-body">
                                <div class="info-row">
                                    <span class="info-label">Mã đơn hàng:</span>
                                    <span class="info-value">#${order.orderId}</span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Ngày tạo:</span>
                                    <span class="info-value">
                                        <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm:ss" />
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Cập nhật lần cuối:</span>
                                    <span class="info-value">
                                        <fmt:formatDate value="${order.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss" />
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Trạng thái:</span>
                                    <span class="info-value">
                                        <c:choose>
                                            <c:when test="${order.status eq 'PENDING'}">
                                                <span class="order-status status-pending">Chờ xử lý</span>
                                            </c:when>
                                            <c:when test="${order.status eq 'PROCESSING'}">
                                                <span class="order-status status-processing">Đang xử lý</span>
                                            </c:when>
                                            <c:when test="${order.status eq 'COMPLETED'}">
                                                <span class="order-status status-completed">Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${order.status eq 'FAILED'}">
                                                <span class="order-status status-failed">Thất bại</span>
                                            </c:when>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Customer Information -->
                        <c:if test="${not empty order.user}">
                            <div class="detail-card">
                                <div class="detail-card-header">
                                    <h5><i class="bi bi-person"></i> Thông tin khách hàng</h5>
                                </div>
                                <div class="detail-card-body">
                                    <div class="user-info">
                                        <div class="user-avatar">
                                            ${order.user.fullName != null ? order.user.fullName.substring(0,1).toUpperCase() : order.user.username.substring(0,1).toUpperCase()}
                                        </div>
                                        <div class="user-details">
                                            <h6>${order.user.fullName != null ? order.user.fullName : order.user.username}</h6>
                                            <p>${order.user.email}</p>
                                            <c:if test="${not empty order.user.phoneNumber}">
                                                <p><i class="bi bi-telephone"></i> ${order.user.phoneNumber}</p>
                                            </c:if>
                                        </div>
                                    </div>
                                    <c:if test="${sessionScope.info.role == 'ADMIN'}">
                                        <div class="mt-3">
                                            <a href="${pageContext.request.contextPath}/admin/orders/history/${order.user.userId}" 
                                               class="btn btn-secondary">
                                                <i class="bi bi-clock-history"></i> Xem lịch sử đơn hàng
                                            </a>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Product Information -->
                        <div class="detail-card">
                            <div class="detail-card-header">
                                <h5><i class="bi bi-box"></i> Thông tin sản phẩm</h5>
                            </div>
                            <div class="detail-card-body">
                                <div class="product-info">
                                    <div class="product-icon">
                                        <i class="bi bi-credit-card"></i>
                                    </div>
                                    <div class="product-details">
                                        <h6>${order.productName}</h6>
                                        <p><i class="bi bi-building"></i> ${order.providerName}</p>
                                    </div>
                                </div>
                                
                                <div class="row mt-4">
                                    <div class="col-sm-4">
                                        <div class="info-row">
                                            <span class="info-label">Số lượng:</span>
                                            <span class="info-value">${order.quantity}</span>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="info-row">
                                            <span class="info-label">Đơn giá:</span>
                                            <span class="info-value">
                                                <fmt:formatNumber value="${order.unitPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="info-row">
                                            <span class="info-label">Tạm tính:</span>
                                            <span class="info-value">
                                                <fmt:formatNumber value="${order.unitPrice * order.quantity}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Product Log (for completed orders) -->
                        <c:if test="${not empty order.productLog and order.status eq 'COMPLETED'}">
                            <div class="detail-card">
                                <div class="detail-card-header">
                                    <h5><i class="bi bi-file-earmark-code"></i> Thông tin thẻ đã giao</h5>
                                </div>
                                <div class="detail-card-body">
                                    <div class="product-log">
                                        <!-- This would need to be parsed from JSON in a real implementation -->
                                        <p class="text-muted mb-3">
                                            <i class="bi bi-info-circle"></i> 
                                            Thông tin chi tiết về thẻ đã được giao cho khách hàng.
                                        </p>
                                        <div class="product-log-item">
                                            <span class="log-label">Dữ liệu thẻ:</span>
                                            <span class="log-value">Đã giao thành công</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </div>
                    
                    <div class="col-lg-4">
                        <!-- Order Summary -->
                        <div class="detail-card">
                            <div class="detail-card-header">
                                <h5><i class="bi bi-calculator"></i> Tóm tắt đơn hàng</h5>
                            </div>
                            <div class="detail-card-body">
                                <div class="info-row">
                                    <span class="info-label">Tạm tính:</span>
                                    <span class="info-value">
                                        <fmt:formatNumber value="${order.unitPrice * order.quantity}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                    </span>
                                </div>
                                
                                <c:if test="${order.discountAmount != null and order.discountAmount > 0}">
                                    <div class="voucher-info">
                                        <div class="voucher-code">
                                            <i class="bi bi-ticket-perforated"></i> ${order.voucherCode}
                                        </div>
                                        <div class="voucher-discount">
                                            Giảm <fmt:formatNumber value="${order.discountAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                        </div>
                                    </div>
                                </c:if>
                                
                                <hr>
                                <div class="info-row">
                                    <span class="info-label"><strong>Tổng cộng:</strong></span>
                                    <span class="info-value price-large">
                                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Order Actions (Only for Admin) -->
                        <c:if test="${sessionScope.info.role == 'ADMIN'}">
                            <div class="detail-card">
                                <div class="detail-card-header">
                                    <h5><i class="bi bi-gear"></i> Thao tác</h5>
                                </div>
                                <div class="detail-card-body">
                                    <div class="action-buttons">
                                        <!-- Status Update Forms -->
                                        <c:if test="${order.status eq 'PENDING'}">
                                            <form method="POST" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                <input type="hidden" name="status" value="PROCESSING">
                                                <button type="submit" class="btn btn-warning">
                                                    <i class="bi bi-play-circle"></i> Bắt đầu xử lý
                                                </button>
                                            </form>
                                        </c:if>
                                        
                                        <c:if test="${order.status eq 'PROCESSING'}">
                                            <form method="POST" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                <input type="hidden" name="status" value="COMPLETED">
                                                <button type="submit" class="btn btn-success">
                                                    <i class="bi bi-check-circle"></i> Hoàn thành
                                                </button>
                                            </form>
                                            
                                            <form method="POST" action="${pageContext.request.contextPath}/admin/orders" style="display: inline;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="${order.orderId}">
                                                <input type="hidden" name="status" value="FAILED">
                                                <button type="submit" class="btn btn-danger" 
                                                        onclick="return confirm('Bạn có chắc chắn muốn đánh dấu đơn hàng này là thất bại?')">
                                                    <i class="bi bi-x-circle"></i> Đánh dấu thất bại
                                                </button>
                                            </form>
                                        </c:if>
                                        
                                        <c:if test="${order.status eq 'COMPLETED' or order.status eq 'FAILED'}">
                                            <div class="alert alert-info mb-3">
                                                <i class="bi bi-info-circle"></i> 
                                                Đơn hàng đã kết thúc (${order.status eq 'COMPLETED' ? 'Hoàn thành' : 'Thất bại'}), không thể thay đổi trạng thái.
                                            </div>
                                        </c:if>
                                        
                                        <!-- Back to Orders List -->
                                        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary">
                                            <i class="bi bi-arrow-left"></i> Quay lại danh sách
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Back Button for Regular Users -->
                        <c:if test="${sessionScope.info.role != 'ADMIN'}">
                            <div class="detail-card">
                                <div class="detail-card-body">
                                    <a href="${pageContext.request.contextPath}/order-history" class="btn btn-secondary">
                                        <i class="bi bi-arrow-left"></i> Quay lại lịch sử đơn hàng
                                    </a>
                                </div>
                            </div>
                        </c:if>
                        
                        <!-- Order Timeline -->
                        <div class="detail-card">
                            <div class="detail-card-header">
                                <h5><i class="bi bi-clock-history"></i> Lịch sử đơn hàng</h5>
                            </div>
                            <div class="detail-card-body">
                                <div class="timeline">
                                    <div class="timeline-item ${order.status eq 'PENDING' ? 'active' : ''}">
                                        <div class="timeline-content">
                                            <div class="timeline-title">Đơn hàng được tạo</div>
                                            <div class="timeline-time">
                                                <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <c:if test="${order.status eq 'PROCESSING' or order.status eq 'COMPLETED' or order.status eq 'FAILED'}">
                                        <div class="timeline-item ${order.status eq 'PROCESSING' ? 'active' : ''}">
                                            <div class="timeline-content">
                                                <div class="timeline-title">Bắt đầu xử lý</div>
                                                <div class="timeline-time">
                                                    <fmt:formatDate value="${order.updatedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                    
                                    <c:if test="${order.status eq 'COMPLETED'}">
                                        <div class="timeline-item active">
                                            <div class="timeline-content">
                                                <div class="timeline-title">Đơn hàng hoàn thành</div>
                                                <div class="timeline-time">
                                                    <fmt:formatDate value="${order.updatedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                    
                                    <c:if test="${order.status eq 'FAILED'}">
                                        <div class="timeline-item active">
                                            <div class="timeline-content">
                                                <div class="timeline-title">Đơn hàng thất bại</div>
                                                <div class="timeline-time">
                                                    <fmt:formatDate value="${order.updatedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
            
            <c:if test="${empty order}">
                <div class="text-center py-5">
                    <i class="bi bi-exclamation-triangle" style="font-size: 4rem; color: #ffc107;"></i>
                    <h3 class="mt-3">Không tìm thấy đơn hàng</h3>
                    <p class="text-muted">Đơn hàng bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.</p>
                    <c:choose>
                        <c:when test="${sessionScope.info.role == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-primary">
                                <i class="bi bi-arrow-left"></i> Quay lại danh sách đơn hàng
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/order-history" class="btn btn-primary">
                                <i class="bi bi-arrow-left"></i> Quay lại lịch sử đơn hàng
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>

