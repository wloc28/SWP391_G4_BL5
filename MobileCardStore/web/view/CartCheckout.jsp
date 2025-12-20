<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Thanh Toán</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .checkout-item {
                transition: all 0.3s ease;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container py-5">
            <h2 class="mb-4">Thanh Toán</h2>
            
            <!-- Error Messages -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            
            <c:if test="${empty items or items.size() == 0}">
                <div class="text-center py-5">
                    <h4 class="text-muted">Giỏ hàng của bạn đang trống</h4>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary mt-3">Tiếp tục mua sắm</a>
                </div>
            </c:if>
            
            <c:if test="${not empty items and items.size() > 0}">
                <form id="checkoutForm">
                    <div class="row">
                        <!-- Order Details -->
                        <div class="col-lg-8">
                            <!-- Customer Information -->
                            <div class="card mb-4">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0">Thông tin khách hàng</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Họ và tên</label>
                                            <input type="text" class="form-control" value="${user.fullName}" readonly>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Email</label>
                                            <input type="email" class="form-control" value="${user.email}" readonly>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Số điện thoại</label>
                                            <input type="text" class="form-control" value="${user.phoneNumber}" readonly>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Order Items -->
                            <div class="card mb-4">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0">Sản phẩm mua</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Sản phẩm</th>
                                                    <th>Nhà cung cấp</th>
                                                    <th class="text-center">Số lượng</th>
                                                    <th class="text-end">Đơn giá</th>
                                                    <th class="text-end">Thành tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${items}">
                                                    <tr class="checkout-item">
                                                        <td>
                                                            <strong>${item.productName}</strong><br>
                                                            <small class="text-muted">Mã: ${item.productCode}</small>
                                                        </td>
                                                        <td>${item.providerName}</td>
                                                        <td class="text-center">${item.quantity}</td>
                                                        <td class="text-end">
                                                            <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                        </td>
                                                        <td class="text-end fw-bold">
                                                            <fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Payment Info -->
                            <div class="card mb-4">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0">Thông tin thanh toán</h5>
                                </div>
                                <div class="card-body">
                                    <div class="alert alert-info mb-0">
                                        <i class="bi bi-info-circle me-2"></i>
                                        <strong>Thanh toán bằng ví:</strong> Số tiền sẽ được trừ trực tiếp từ số dư ví của bạn.
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Order Summary -->
                        <div class="col-lg-4">
                            <div class="card sticky-top" style="top: 20px;">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0">Tóm tắt đơn hàng</h5>
                                </div>
                                <div class="card-body">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span>Tạm tính:</span>
                                        <strong><fmt:formatNumber value="${subtotal}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/></strong>
                                    </div>
                                    
                                    <c:if test="${not empty cart.voucher}">
                                        <div class="d-flex justify-content-between mb-2 text-success">
                                            <span>Giảm giá (${cart.voucher.code}):</span>
                                            <strong>-<fmt:formatNumber value="${discount}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/></strong>
                                        </div>
                                    </c:if>
                                    
                                    <hr>
                                    <div class="d-flex justify-content-between mb-3">
                                        <span class="fs-5 fw-bold">Tổng cộng:</span>
                                        <strong class="fs-5 text-primary">
                                            <fmt:formatNumber value="${total}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                        </strong>
                                    </div>
                                    
                                    <div class="d-grid gap-2">
                                        <button type="button" class="btn btn-primary btn-lg" onclick="processCheckout()">
                                            <i class="bi bi-credit-card"></i> Thanh toán
                                        </button>
                                        <a href="${pageContext.request.contextPath}/cart/view" class="btn btn-outline-secondary">
                                            Quay lại giỏ hàng
                                        </a>
                                    </div>
                                    
                                    <div id="checkoutMessage" class="mt-3"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </c:if>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            function processCheckout() {
                const messageDiv = document.getElementById('checkoutMessage');
                const submitBtn = event.target;
                
                if (!confirm('Bạn có chắc chắn muốn thanh toán? Số tiền sẽ được trừ trực tiếp từ ví của bạn.')) {
                    return;
                }
                
                messageDiv.innerHTML = '<div class="alert alert-info">Đang xử lý đơn hàng...</div>';
                submitBtn.disabled = true;
                
                fetch('${pageContext.request.contextPath}/cart/process-checkout', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    }
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const orderHistoryUrl = data.orderHistoryUrl || data.redirect || '${pageContext.request.contextPath}/order-history';
                        messageDiv.innerHTML = '<div class="alert alert-success">' +
                            '<h5 class="alert-heading"><i class="bi bi-check-circle-fill"></i> ' + data.message + '</h5>' +
                            '<hr>' +
                            '<p class="mb-0">' +
                            '<a href="' + orderHistoryUrl + '" class="alert-link fw-bold">' +
                            '<i class="bi bi-box-seam"></i> Click tại đây để xem đơn hàng</a>' +
                            '</p>' +
                            '</div>';
                        
                        // Tự động chuyển sau 5 giây
                        setTimeout(() => {
                            window.location.href = orderHistoryUrl;
                        }, 5000);
                    } else {
                        messageDiv.innerHTML = '<div class="alert alert-danger">' +
                            '<h5 class="alert-heading"><i class="bi bi-exclamation-triangle-fill"></i> Lỗi</h5>' +
                            '<p class="mb-0">' + data.message + '</p>' +
                            '</div>';
                        submitBtn.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    messageDiv.innerHTML = '<div class="alert alert-danger">Có lỗi xảy ra khi đặt hàng</div>';
                    submitBtn.disabled = false;
                });
            }
        </script>
    </body>
</html>
