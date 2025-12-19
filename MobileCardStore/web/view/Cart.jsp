<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Giỏ hàng</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .cart-item {
                border-bottom: 1px solid #e0e0e0;
                padding: 20px 0;
                margin-bottom: 10px;
                min-height: 100px;
                display: block;
            }
            .cart-item:last-child {
                border-bottom: none;
            }
            .cart-item .row {
                margin: 0;
            }
            .price-old {
                text-decoration: line-through;
                color: #999;
            }
            .voucher-section {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 20px;
                margin-bottom: 20px;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container py-4">
            <h2 class="mb-4">
                <i class="bi bi-cart"></i> Giỏ hàng của tôi
            </h2>
            
            <!-- Success/Error Messages -->
            <c:if test="${not empty param.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <c:choose>
                        <c:when test="${param.success == 'added_to_cart'}">
                            <i class="bi bi-check-circle"></i> Đã thêm sản phẩm vào giỏ hàng!
                        </c:when>
                        <c:when test="${param.success == 'updated'}">
                            <i class="bi bi-check-circle"></i> Đã cập nhật giỏ hàng!
                        </c:when>
                        <c:when test="${param.success == 'removed'}">
                            <i class="bi bi-check-circle"></i> Đã xóa sản phẩm khỏi giỏ hàng!
                        </c:when>
                        <c:when test="${param.success == 'voucher_applied'}">
                            <i class="bi bi-check-circle"></i> Đã áp dụng voucher thành công!
                        </c:when>
                        <c:when test="${param.success == 'voucher_removed'}">
                            <i class="bi bi-check-circle"></i> Đã xóa voucher!
                        </c:when>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <c:choose>
                        <c:when test="${param.error == 'invalid_params'}">
                            <i class="bi bi-exclamation-triangle"></i> Thông tin không hợp lệ!
                        </c:when>
                        <c:when test="${param.error == 'product_not_found'}">
                            <i class="bi bi-exclamation-triangle"></i> Không tìm thấy sản phẩm!
                        </c:when>
                        <c:when test="${param.error == 'insufficient_stock'}">
                            <i class="bi bi-exclamation-triangle"></i> Số lượng sản phẩm không đủ!
                        </c:when>
                        <c:when test="${param.error == 'voucher_not_found'}">
                            <i class="bi bi-exclamation-triangle"></i> Mã voucher không tồn tại!
                        </c:when>
                        <c:when test="${param.error == 'voucher_inactive'}">
                            <i class="bi bi-exclamation-triangle"></i> Voucher không còn hiệu lực!
                        </c:when>
                        <c:when test="${param.error == 'voucher_expired'}">
                            <i class="bi bi-exclamation-triangle"></i> Voucher đã hết hạn!
                        </c:when>
                        <c:when test="${param.error == 'voucher_limit_reached'}">
                            <i class="bi bi-exclamation-triangle"></i> Voucher đã hết lượt sử dụng!
                        </c:when>
                        <c:when test="${param.error == 'min_order_not_met'}">
                            <i class="bi bi-exclamation-triangle"></i> Đơn hàng tối thiểu chưa đạt! 
                            <c:if test="${not empty param.minOrder}">
                                (Tối thiểu: <fmt:formatNumber value="${param.minOrder}" type="number" maxFractionDigits="0"/> đ)
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-exclamation-triangle"></i> Có lỗi xảy ra: ${param.error}
                        </c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            
            <c:choose>
                <c:when test="${empty cartItems or cartItems.size() == 0}">
                    <div class="text-center py-5">
                        <i class="bi bi-cart-x" style="font-size: 4rem; color: #ccc;"></i>
                        <h4 class="mt-3 text-muted">Giỏ hàng của bạn đang trống</h4>
                        <p class="text-muted">Hãy thêm sản phẩm vào giỏ hàng để tiếp tục mua sắm</p>
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-3">
                            <i class="bi bi-house"></i> Về trang chủ
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row">
                        <!-- Cart Items -->
                        <div class="col-lg-8">
                            <div class="card">
                                <div class="card-body">
                                    <h5 class="card-title mb-4">
                                        Sản phẩm trong giỏ hàng 
                                        <span class="badge bg-secondary">(${cartItems.size()} sản phẩm)</span>
                                    </h5>
                                    
                                    <!-- Debug: Hiển thị số lượng items -->
                                    <div class="alert alert-info small mb-3" style="display: none;" id="debugInfo">
                                        <strong>Debug Info:</strong><br>
                                        Total items in list: ${cartItems.size()}<br>
                                        <c:forEach var="item" items="${cartItems}" varStatus="status">
                                            Item ${status.index + 1}: ID=${item.cartItemId}, Code=${item.productCode}, Provider=${item.providerId}, Qty=${item.quantity}<br>
                                        </c:forEach>
                                    </div>
                                    
                                    <c:forEach var="item" items="${cartItems}" varStatus="status">
                                        <div class="cart-item">
                                            <div class="row align-items-center">
                                                <div class="col-md-6">
                                                    <h6 class="mb-1">${item.productName}</h6>
                                                    <p class="text-muted mb-1 small">
                                                        <span class="badge bg-primary">${item.providerName}</span>
                                                        <span class="ms-2">Mã: ${item.productCode}</span>
                                                    </p>
                                                    <c:if test="${item.product != null and item.product.price.compareTo(item.unitPrice) != 0}">
                                                        <p class="text-warning small mb-0">
                                                            <i class="bi bi-exclamation-triangle"></i> Giá sản phẩm đã thay đổi
                                                        </p>
                                                    </c:if>
                                                </div>
                                                <div class="col-md-2 text-center">
                                                    <p class="mb-0">
                                                        <strong><fmt:formatNumber value="${item.unitPrice}" type="number" maxFractionDigits="0"/> đ</strong>
                                                    </p>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="input-group input-group-sm">
                                                        <button class="btn btn-outline-secondary" type="button" 
                                                                onclick="updateQuantity(${item.cartItemId}, parseInt(document.getElementById('qty_${item.cartItemId}').value) - 1)">-</button>
                                                        <input type="number" class="form-control text-center" 
                                                               value="${item.quantity}" min="1" 
                                                               onchange="updateQuantity(${item.cartItemId}, this.value)" 
                                                               id="qty_${item.cartItemId}">
                                                        <button class="btn btn-outline-secondary" type="button" 
                                                                onclick="updateQuantity(${item.cartItemId}, parseInt(document.getElementById('qty_${item.cartItemId}').value) + 1)">+</button>
                                                    </div>
                                                </div>
                                                <div class="col-md-2 text-end">
                                                    <p class="mb-1">
                                                        <strong class="text-primary">
                                                            <fmt:formatNumber value="${item.subtotal}" type="number" maxFractionDigits="0"/> đ
                                                        </strong>
                                                    </p>
                                                    <button class="btn btn-sm btn-outline-danger" 
                                                            onclick="removeItem(${item.cartItemId})">
                                                        <i class="bi bi-trash"></i> Xóa
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Order Summary -->
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-body">
                                    <h5 class="card-title mb-4">Tóm tắt đơn hàng</h5>
                                    
                                    <!-- Voucher Section -->
                                    <div class="voucher-section mb-4">
                                        <h6 class="mb-3">
                                            <i class="bi bi-ticket-perforated"></i> Mã giảm giá
                                        </h6>
                                        <c:choose>
                                            <c:when test="${cart.voucher != null}">
                                                <div class="alert alert-success mb-2">
                                                    <div class="d-flex justify-content-between align-items-center">
                                                        <div>
                                                            <strong>${cart.voucher.code}</strong>
                                                            <br>
                                                            <small>
                                                                <c:choose>
                                                                    <c:when test="${cart.voucher.discountType == 'PERCENT'}">
                                                                        Giảm ${cart.voucher.discountValue}%
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        Giảm <fmt:formatNumber value="${cart.voucher.discountValue}" type="number" maxFractionDigits="0"/> đ
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </small>
                                                        </div>
                                                        <button class="btn btn-sm btn-outline-danger" 
                                                                onclick="removeVoucher()">
                                                            <i class="bi bi-x"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="POST" action="${pageContext.request.contextPath}/cart" class="d-flex gap-2">
                                                    <input type="hidden" name="action" value="applyVoucher">
                                                    <select name="voucherId" class="form-select form-select-sm" required>
                                                        <option value="">-- Chọn mã giảm giá --</option>
                                                        <c:forEach var="voucher" items="${availableVouchers}">
                                                            <option value="${voucher.voucherId}">
                                                                ${voucher.code} - 
                                                                <c:choose>
                                                                    <c:when test="${voucher.discountType == 'PERCENT'}">
                                                                        Giảm ${voucher.discountValue}%
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        Giảm <fmt:formatNumber value="${voucher.discountValue}" type="number" maxFractionDigits="0"/> đ
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <c:if test="${voucher.minOrderValue.compareTo(java.math.BigDecimal.ZERO) > 0}">
                                                                    (Đơn tối thiểu: <fmt:formatNumber value="${voucher.minOrderValue}" type="number" maxFractionDigits="0"/> đ)
                                                                </c:if>
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                    <button type="submit" class="btn btn-primary btn-sm">
                                                        Áp dụng
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <!-- Price Summary -->
                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Tạm tính:</span>
                                            <strong><fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0"/> đ</strong>
                                        </div>
                                        <c:if test="${cart.voucher != null and discount.compareTo(java.math.BigDecimal.ZERO) > 0}">
                                            <div class="d-flex justify-content-between mb-2 text-success">
                                                <span>Giảm giá:</span>
                                                <strong>-<fmt:formatNumber value="${discount}" type="number" maxFractionDigits="0"/> đ</strong>
                                            </div>
                                        </c:if>
                                        <hr>
                                        <div class="d-flex justify-content-between">
                                            <strong>Tổng cộng:</strong>
                                            <strong class="text-primary fs-5">
                                                <fmt:formatNumber value="${total}" type="number" maxFractionDigits="0"/> đ
                                            </strong>
                                        </div>
                                    </div>
                                    
                                    <button class="btn btn-primary w-100 mb-2" onclick="checkout()">
                                        <i class="bi bi-bag-check"></i> Thanh toán
                                    </button>
                                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary w-100">
                                        <i class="bi bi-arrow-left"></i> Tiếp tục mua sắm
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            // Debug: Log cart items khi trang load
            console.log('=== CART DEBUG INFO ===');
            console.log('Total items in cartItems list:', ${cartItems.size()});
            <c:forEach var="item" items="${cartItems}" varStatus="status">
                console.log('Item ${status.index + 1}:', {
                    cartItemId: ${item.cartItemId},
                    productCode: '${item.productCode}',
                    providerId: ${item.providerId},
                    productName: '${item.productName}',
                    providerName: '${item.providerName}',
                    quantity: ${item.quantity},
                    unitPrice: ${item.unitPrice}
                });
            </c:forEach>
            console.log('=== END CART DEBUG ===');
            
            // Hiển thị debug info khi nhấn Ctrl+D
            document.addEventListener('keydown', function(e) {
                if (e.ctrlKey && e.key === 'd') {
                    e.preventDefault();
                    const debugInfo = document.getElementById('debugInfo');
                    if (debugInfo) {
                        debugInfo.style.display = debugInfo.style.display === 'none' ? 'block' : 'none';
                    }
                }
            });
            
            function updateQuantity(cartItemId, quantity) {
                // Đảm bảo quantity là số nguyên và >= 1
                quantity = parseInt(quantity);
                if (isNaN(quantity) || quantity < 1) {
                    quantity = 1;
                }
                
                // Cập nhật giá trị trong input để hiển thị ngay
                const qtyInput = document.getElementById('qty_' + cartItemId);
                if (qtyInput) {
                    qtyInput.value = quantity;
                }
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/cart';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'update';
                form.appendChild(actionInput);
                
                const cartItemIdInput = document.createElement('input');
                cartItemIdInput.type = 'hidden';
                cartItemIdInput.name = 'cartItemId';
                cartItemIdInput.value = cartItemId;
                form.appendChild(cartItemIdInput);
                
                const quantityInput = document.createElement('input');
                quantityInput.type = 'hidden';
                quantityInput.name = 'quantity';
                quantityInput.value = quantity;
                form.appendChild(quantityInput);
                
                document.body.appendChild(form);
                form.submit();
            }
            
            function removeItem(cartItemId) {
                if (!confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?')) {
                    return;
                }
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/cart';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'remove';
                form.appendChild(actionInput);
                
                const cartItemIdInput = document.createElement('input');
                cartItemIdInput.type = 'hidden';
                cartItemIdInput.name = 'cartItemId';
                cartItemIdInput.value = cartItemId;
                form.appendChild(cartItemIdInput);
                
                document.body.appendChild(form);
                form.submit();
            }
            
            function removeVoucher() {
                if (!confirm('Bạn có muốn xóa voucher này?')) {
                    return;
                }
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/cart';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'removeVoucher';
                form.appendChild(actionInput);
                
                document.body.appendChild(form);
                form.submit();
            }
            
            function checkout() {
                alert('Tính năng thanh toán sẽ được triển khai sau!');
                // TODO: Implement checkout functionality
            }
        </script>
    </body>
</html>

