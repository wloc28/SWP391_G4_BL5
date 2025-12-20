<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Giỏ Hàng</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .cart-item {
                transition: all 0.3s ease;
            }
            .cart-item:hover {
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            }
            .quantity-input {
                width: 60px;
                text-align: center;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container py-5">
            <h2 class="mb-4">Giỏ Hàng Của Bạn</h2>
            
            <!-- Error/Success Messages -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            
            <c:if test="${empty items or items.size() == 0}">
                <div class="text-center py-5">
                    <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="currentColor" class="bi bi-cart-x text-muted mb-3" viewBox="0 0 16 16">
                        <path d="M7.354 5.646a.5.5 0 1 0-.708.708L7.793 7.5 6.646 8.646a.5.5 0 1 0 .708.708L8.5 8.207l1.146 1.147a.5.5 0 0 0 .708-.708L9.207 7.5l1.147-1.146a.5.5 0 0 0-.708-.708L8.5 6.793 7.354 5.646Z"/>
                        <path d="M.5 1a.5.5 0 0 0 0 1h1.11l.401 1.607 1.498 7.985A.5.5 0 0 0 4 12h1a2 2 0 1 0 0 4 2 2 0 0 0 0-4h7a2 2 0 1 0 0 4 2 2 0 0 0 0-4h1a.5.5 0 0 0 .491-.408l1.5-8A.5.5 0 0 0 14.5 3H2.89l-.405-1.621A.5.5 0 0 0 2 1H.5Zm3.915 10L3.102 4h10.796l-1.313 7h-8.17ZM6 14a1 1 0 1 1-2 0 1 1 0 0 1 2 0Zm7 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z"/>
                    </svg>
                    <h4 class="text-muted">Giỏ hàng của bạn đang trống</h4>
                    <p class="text-muted">Hãy thêm sản phẩm vào giỏ hàng để tiếp tục mua sắm</p>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-primary mt-3">Tiếp tục mua sắm</a>
                </div>
            </c:if>
            
            <c:if test="${not empty items and items.size() > 0}">
                <div class="row">
                    <!-- Cart Items -->
                    <div class="col-lg-8">
                        <div class="card">
                            <div class="card-body">
                                <c:forEach var="item" items="${items}">
                                    <div class="cart-item border-bottom pb-3 mb-3">
                                        <div class="row align-items-center">
                                            <div class="col-md-6">
                                                <h5 class="mb-1">${item.productName}</h5>
                                                <p class="text-muted mb-0">
                                                    <small>Nhà cung cấp: ${item.providerName}</small><br>
                                                    <small>Mã sản phẩm: ${item.productCode}</small>
                                                </p>
                                            </div>
                                            <div class="col-md-2 text-center">
                                                <label class="form-label">Số lượng</label>
                                                <div class="input-group input-group-sm">
                                                    <button class="btn btn-outline-secondary" type="button" 
                                                            onclick="updateQuantity(${item.cartItemId}, ${item.quantity - 1})">-</button>
                                                    <input type="number" class="form-control quantity-input" 
                                                           id="qty-${item.cartItemId}" value="${item.quantity}" 
                                                           min="1" onchange="updateQuantity(${item.cartItemId}, this.value)">
                                                    <button class="btn btn-outline-secondary" type="button" 
                                                            onclick="updateQuantity(${item.cartItemId}, ${item.quantity + 1})">+</button>
                                                </div>
                                            </div>
                                            <div class="col-md-2 text-center">
                                                <label class="form-label">Đơn giá</label>
                                                <p class="mb-0 fw-bold">
                                                    <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                </p>
                                            </div>
                                            <div class="col-md-2 text-center">
                                                <label class="form-label">Thành tiền</label>
                                                <p class="mb-0 fw-bold text-primary">
                                                    <fmt:formatNumber value="${item.subtotal}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                                </p>
                                                <button class="btn btn-sm btn-danger mt-2" onclick="removeItem(${item.cartItemId})">
                                                    <i class="bi bi-trash"></i> Xóa
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Cart Summary -->
                    <div class="col-lg-4">
                        <div class="card">
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
                                    <div class="mb-3">
                                        <button class="btn btn-sm btn-outline-danger" onclick="removeVoucher()">
                                            Xóa voucher
                                        </button>
                                    </div>
                                </c:if>
                                
                                <c:if test="${empty cart.voucher}">
                                    <div class="mb-3">
                                        <label class="form-label">Mã giảm giá</label>
                                        <c:choose>
                                            <c:when test="${availableVouchers != null && not empty availableVouchers && availableVouchers.size() > 0}">
                                                <select class="form-select" id="voucherCode" onchange="applyVoucherFromDropdown()">
                                                    <option value="">-- Chọn mã giảm giá --</option>
                                                    <c:forEach var="voucher" items="${availableVouchers}">
                                                        <option value="${voucher.code}">
                                                            ${voucher.code} - 
                                                            <c:choose>
                                                                <c:when test="${voucher.discountType == 'PERCENT'}">
                                                                    Giảm <fmt:formatNumber value="${voucher.discountValue}" type="number" maxFractionDigits="0"/>%
                                                                </c:when>
                                                                <c:otherwise>
                                                                    Giảm <fmt:formatNumber value="${voucher.discountValue}" type="number" maxFractionDigits="0"/> đ
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <c:if test="${voucher.minOrderValue != null && voucher.minOrderValue.doubleValue() > 0}">
                                                                (Đơn tối thiểu <fmt:formatNumber value="${voucher.minOrderValue}" type="number" maxFractionDigits="0"/> đ)
                                                            </c:if>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="alert alert-info mb-0">
                                                    <small><i class="bi bi-info-circle"></i> Hiện không có mã giảm giá khả dụng cho đơn hàng này</small>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div id="voucherMessage" class="mt-2"></div>
                                    </div>
                                </c:if>
                                
                                <hr>
                                <div class="d-flex justify-content-between mb-3">
                                    <span class="fs-5 fw-bold">Tổng cộng:</span>
                                    <strong class="fs-5 text-primary">
                                        <fmt:formatNumber value="${total}" type="currency" currencySymbol="VNĐ" maxFractionDigits="0"/>
                                    </strong>
                                </div>
                                
                                <a href="${pageContext.request.contextPath}/cart/checkout" class="btn btn-primary w-100">
                                    Tiến hành thanh toán
                                </a>
                                <a href="${pageContext.request.contextPath}/products" class="btn btn-outline-secondary w-100 mt-2">
                                    Tiếp tục mua sắm
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            function updateQuantity(cartItemId, newQuantity) {
                if (newQuantity < 1) {
                    newQuantity = 1;
                }
                
                fetch('${pageContext.request.contextPath}/cart/update', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'cartItemId=' + cartItemId + '&quantity=' + newQuantity
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert(data.message || 'Có lỗi xảy ra');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi cập nhật số lượng');
                });
            }
            
            function removeItem(cartItemId) {
                if (!confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?')) {
                    return;
                }
                
                fetch('${pageContext.request.contextPath}/cart/remove', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'cartItemId=' + cartItemId
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert(data.message || 'Có lỗi xảy ra');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi xóa sản phẩm');
                });
            }
            
            function applyVoucherFromDropdown() {
                const voucherSelect = document.getElementById('voucherCode');
                const voucherCode = voucherSelect ? voucherSelect.value.trim() : '';
                const messageDiv = document.getElementById('voucherMessage');
                
                if (!voucherCode) {
                    messageDiv.innerHTML = '';
                    return;
                }
                
                messageDiv.innerHTML = '<div class="text-info"><small>Đang xử lý...</small></div>';
                
                fetch('${pageContext.request.contextPath}/cart/apply-voucher', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'voucherCode=' + encodeURIComponent(voucherCode)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        messageDiv.innerHTML = '<div class="text-success"><small>' + data.message + '</small></div>';
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        messageDiv.innerHTML = '<div class="text-danger"><small>' + data.message + '</small></div>';
                        // Reset dropdown về giá trị rỗng
                        if (voucherSelect) {
                            voucherSelect.value = '';
                        }
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    messageDiv.innerHTML = '<div class="text-danger"><small>Có lỗi xảy ra</small></div>';
                    // Reset dropdown về giá trị rỗng
                    if (voucherSelect) {
                        voucherSelect.value = '';
                    }
                });
            }
            
            // Giữ lại function cũ để tương thích (nếu có nơi nào gọi)
            function applyVoucher() {
                applyVoucherFromDropdown();
            }
            
            function removeVoucher() {
                if (!confirm('Bạn có chắc chắn muốn xóa voucher?')) {
                    return;
                }
                
                fetch('${pageContext.request.contextPath}/cart/remove-voucher', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    }
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert(data.message || 'Có lỗi xảy ra');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra');
                });
            }
        </script>
    </body>
</html>


