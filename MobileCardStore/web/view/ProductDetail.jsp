<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chi Tiết Sản Phẩm</title>
        <%@include file="../components/libs.jsp" %>
        <script src="https://cdn.tailwindcss.com"></script>
        <style>
            .line-clamp-2 {
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }
            .aspect-square {
                aspect-ratio: 1 / 1;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="w-full px-4 py-6">
            <div class="max-w-6xl mx-auto">
                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <div class="bg-red-50 border border-red-200 rounded-lg p-3 mb-4">
                        <div class="flex justify-between items-center">
                            <p class="text-red-800 text-sm">${error}</p>
                            <button type="button" onclick="this.parentElement.parentElement.remove()" class="text-red-600 hover:text-red-800">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                    <a href="products" class="inline-block bg-gray-900 text-white px-3 py-1.5 rounded text-sm hover:bg-gray-800 transition-colors font-medium mb-4">Quay lại</a>
                </c:if>
                
                <!-- Product Detail -->
                <c:if test="${not empty product}">
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- Product Image -->
                        <div>
                            <c:choose>
                                <c:when test="${not empty product.providerImageUrl}">
                                    <img src="${product.providerImageUrl}" class="w-full rounded-lg border border-gray-200 bg-gray-100 p-8" 
                                         alt="${product.productName}" 
                                         style="object-fit: contain; min-height: 400px;"
                                         onerror="this.src='https://via.placeholder.com/500x500?text=No+Image'">
                                </c:when>
                                <c:otherwise>
                                    <div class="w-full rounded-lg border border-gray-200 bg-gray-100 flex items-center justify-center" style="min-height: 400px;">
                                        <i class="bi bi-credit-card-2-front" style="font-size: 5rem; color: #6c757d;"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Product Information -->
                        <div>
                            <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-4">
                                <h1 class="text-xl font-bold text-gray-900 mb-2">${product.productName}</h1>
                                
                                <!-- Provider Info -->
                                <div class="flex gap-2 mb-2">
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">${product.providerName}</span>
                                    <c:if test="${not empty product.providerType}">
                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                            <c:choose>
                                                <c:when test="${product.providerType == 'TEL'}">Thẻ điện thoại</c:when>
                                                <c:when test="${product.providerType == 'GAME'}">Thẻ game</c:when>
                                                <c:otherwise>${product.providerType}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:if>
                                </div>
                                
                                <!-- Price -->
                                <div class="mb-3 pb-3 border-b border-gray-200">
                                    <p class="text-xs text-gray-600 mb-1">Giá bán</p>
                                    <p class="text-2xl font-bold text-red-600">
                                        <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0" /> đ
                                    </p>
                                </div>
                                
                                <!-- Stock Status -->
                                <div class="mb-3">
                                    <c:choose>
                                        <c:when test="${stock > 0}">
                                            <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-green-100 text-green-800">
                                                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                                                </svg>
                                                Còn hàng: ${stock} sản phẩm
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-red-100 text-red-800">
                                                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                                                </svg>
                                                Hết hàng
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                                <!-- Description -->
                                <c:if test="${not empty product.description}">
                                    <div class="mb-3">
                                        <h3 class="text-sm font-semibold text-gray-900 mb-1">Mô tả</h3>
                                        <p class="text-sm text-gray-600 leading-relaxed">${product.description}</p>
                                    </div>
                                </c:if>
                                
                                <!-- Product Details - More compact -->
                                <div class="mb-4">
                                    <h3 class="text-sm font-semibold text-gray-900 mb-2">Thông tin sản phẩm</h3>
                                    <div class="bg-gray-50 p-3 rounded-lg">
                                        <div class="grid grid-cols-2 gap-2 text-xs">
                                            <div>
                                                <span class="font-medium text-gray-500">Mã SP:</span>
                                                <span class="text-gray-900">${product.productCode}</span>
                                            </div>
                                            <div>
                                                <span class="font-medium text-gray-500">Trạng thái:</span>
                                                <c:choose>
                                                    <c:when test="${product.status == 'ACTIVE'}">
                                                        <span class="text-green-600">Đang bán</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-gray-500">Ngừng bán</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Quantity Selector -->
                                <c:if test="${stock > 0 and (sessionScope.info != null or sessionScope.user != null)}">
                                    <div class="mb-3">
                                        <label class="text-sm font-medium text-gray-700 mb-1 block">Số lượng:</label>
                                        <div class="flex items-center gap-2">
                                            <button type="button" onclick="decreaseQuantity()" 
                                                    class="bg-gray-200 hover:bg-gray-300 px-3 py-1 rounded text-sm font-medium">
                                                -
                                            </button>
                                            <input type="number" id="quantity" value="1" min="1" max="${stock}" 
                                                   class="w-20 text-center border border-gray-300 rounded px-2 py-1 text-sm">
                                            <button type="button" onclick="increaseQuantity()" 
                                                    class="bg-gray-200 hover:bg-gray-300 px-3 py-1 rounded text-sm font-medium">
                                                +
                                            </button>
                                            <span class="text-xs text-gray-500">(Còn ${stock} sản phẩm)</span>
                                        </div>
                                    </div>
                                </c:if>
                                
                                <!-- Action Buttons -->
                                <div class="flex gap-2">
                                    <c:choose>
                                        <c:when test="${sessionScope.info == null and sessionScope.user == null}">
                                            <button onclick="alert('Vui lòng đăng nhập để mua hàng!'); window.location.href='${pageContext.request.contextPath}/view/login.jsp';" 
                                                    class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                Đăng nhập để mua hàng
                                            </button>
                                        </c:when>
                                        <c:when test="${stock > 0}">
                                            <button onclick="addToCart('${product.productCode}', ${product.providerId})" 
                                                    class="flex-1 bg-white text-gray-900 border-2 border-gray-900 px-4 py-2 rounded hover:bg-gray-50 transition-colors font-medium text-sm">
                                                <i class="bi bi-cart-plus"></i> Thêm vào giỏ hàng
                                            </button>
                                            <button onclick="buyNow('${product.productCode}', ${product.providerId})" 
                                                    class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                <i class="bi bi-bag-check"></i> Mua ngay
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button disabled 
                                                    class="flex-1 bg-gray-300 text-gray-500 px-4 py-2 rounded cursor-not-allowed font-medium text-sm">
                                                Không thể mua
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <a href="products" class="bg-white text-gray-700 border border-gray-300 px-4 py-2 rounded hover:bg-gray-50 transition-colors font-medium text-sm text-center">
                                        Quay lại
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Related Products Section -->
                    <c:if test="${not empty relatedProducts}">
                        <div class="mt-6">
                            <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-3">
                                <h2 class="text-base font-semibold text-gray-900 mb-3">Sản phẩm liên quan</h2>
                                <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
                                    <c:forEach var="relatedProduct" items="${relatedProducts}">
                                        <div class="bg-gray-50 border border-gray-200 rounded-md overflow-hidden hover:shadow-sm transition-shadow duration-200 cursor-pointer" 
                                             onclick="window.location.href='${pageContext.request.contextPath}/product-detail?code=${relatedProduct.productCode}&providerId=${relatedProduct.providerId}'">
                                            <!-- Product Image -->
                                            <div class="aspect-square bg-white">
                                                <c:choose>
                                                    <c:when test="${not empty relatedProduct.providerImageUrl}">
                                                        <img src="${relatedProduct.providerImageUrl}" 
                                                             class="w-full h-full object-contain p-2" 
                                                             alt="${relatedProduct.productName}"
                                                             onerror="this.src='https://via.placeholder.com/150x150?text=No+Image'">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="w-full h-full flex items-center justify-center">
                                                            <i class="bi bi-credit-card-2-front" style="font-size: 2rem; color: #6c757d;"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            
                                            <!-- Product Info -->
                                            <div class="p-2">
                                                <h3 class="text-xs font-medium text-gray-900 mb-0.5 line-clamp-2">${relatedProduct.productName}</h3>
                                                <div class="flex items-center justify-between">
                                                    <span class="text-xs font-bold text-red-600">
                                                        <fmt:formatNumber value="${relatedProduct.price}" type="number" maxFractionDigits="0" />đ
                                                    </span>
                                                    <span class="inline-flex items-center px-1 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-700">
                                                        ${relatedProduct.providerName}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </c:if>
                
                <!-- Feedback Section -->
                <c:if test="${not empty product}">
                    <div class="max-w-6xl mx-auto mt-8">
                        <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
                            <h2 class="text-xl font-bold text-gray-900 mb-4">Bình luận</h2>
                            
                            <!-- Error Messages -->
                            <c:if test="${param.error == 'content_too_long'}">
                                <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                                    <p class="text-red-800 text-sm">
                                        <i class="bi bi-exclamation-circle"></i> 
                                        Nội dung không được vượt quá 100 ký tự!
                                    </p>
                                </div>
                            </c:if>
                            
                            <!-- Feedback Form (chỉ hiển thị nếu user đã đăng nhập và chưa feedback) -->
                            <c:if test="${not empty sessionScope.user}">
                                <c:if test="${!hasFeedbacked}">
                                    <div class="mb-6">
                                        <form action="${pageContext.request.contextPath}/feedback/add" method="POST">
                                            <input type="hidden" name="productId" value="${product.providerStorageId}">
                                            <input type="hidden" name="code" value="${product.productCode}">
                                            <input type="hidden" name="providerId" value="${product.providerId}">
                                            <div class="mb-3">
                                                <label class="block text-sm font-medium text-gray-700 mb-2">Đánh giá:</label>
                                                <input type="hidden" name="rating" id="ratingValue" value="">
                                                <div class="flex items-center gap-1" id="starRating" onmouseleave="resetStarHover()">
                                                    <span class="text-2xl cursor-pointer text-gray-300 transition-colors star-item" 
                                                          data-rating="1" 
                                                          onclick="selectRating(1)"
                                                          onmouseenter="hoverRating(1)">★</span>
                                                    <span class="text-2xl cursor-pointer text-gray-300 transition-colors star-item" 
                                                          data-rating="2" 
                                                          onclick="selectRating(2)"
                                                          onmouseenter="hoverRating(2)">★</span>
                                                    <span class="text-2xl cursor-pointer text-gray-300 transition-colors star-item" 
                                                          data-rating="3" 
                                                          onclick="selectRating(3)"
                                                          onmouseenter="hoverRating(3)">★</span>
                                                    <span class="text-2xl cursor-pointer text-gray-300 transition-colors star-item" 
                                                          data-rating="4" 
                                                          onclick="selectRating(4)"
                                                          onmouseenter="hoverRating(4)">★</span>
                                                    <span class="text-2xl cursor-pointer text-gray-300 transition-colors star-item" 
                                                          data-rating="5" 
                                                          onclick="selectRating(5)"
                                                          onmouseenter="hoverRating(5)">★</span>
                                                </div>
                                            </div>
                                            <textarea name="content" rows="4" 
                                                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-gray-900 focus:border-transparent"
                                                      placeholder="Nhập nội dung bình luận (không bắt buộc)"
                                                      maxlength="100"
                                                      oninput="updateCharCount(this, 'contentCount')"></textarea>
                                            <div class="text-sm text-gray-500 mt-1 text-right">
                                                <span id="contentCount">0</span>/100 ký tự
                                            </div>
                                            <div class="mt-3 flex justify-end">
                                                <button type="submit" 
                                                        class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors">
                                                    Gửi bình luận
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </c:if>
                                
                                <c:if test="${hasFeedbacked}">
                                    <div class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                                        <p class="text-sm text-blue-800 mb-2">Bạn đã gửi feedback cho sản phẩm này rồi.</p>
                                        <c:if test="${not empty currentUserFeedback}">
                                            <form action="${pageContext.request.contextPath}/feedback/update-rating" method="POST" class="flex items-center gap-2">
                                                <input type="hidden" name="feedbackId" value="${currentUserFeedback.feedbackId}">
                                                <input type="hidden" name="productId" value="${product.providerStorageId}">
                                                <input type="hidden" name="code" value="${product.productCode}">
                                                <input type="hidden" name="providerId" value="${product.providerId}">
                                                <input type="hidden" name="rating" id="editRatingValue" value="${currentUserFeedback.rating}">
                                                <label class="text-sm text-gray-700">Sửa đánh giá:</label>
                                                <div class="flex items-center gap-1" id="editStarRating" onmouseleave="resetEditStarHover()">
                                                    <span class="text-xl cursor-pointer transition-colors edit-star-item ${currentUserFeedback.rating >= 1 ? 'text-yellow-400' : 'text-gray-300'}" 
                                                          data-rating="1" 
                                                          onclick="selectEditRating(1)"
                                                          onmouseenter="hoverEditRating(1)">★</span>
                                                    <span class="text-xl cursor-pointer transition-colors edit-star-item ${currentUserFeedback.rating >= 2 ? 'text-yellow-400' : 'text-gray-300'}" 
                                                          data-rating="2" 
                                                          onclick="selectEditRating(2)"
                                                          onmouseenter="hoverEditRating(2)">★</span>
                                                    <span class="text-xl cursor-pointer transition-colors edit-star-item ${currentUserFeedback.rating >= 3 ? 'text-yellow-400' : 'text-gray-300'}" 
                                                          data-rating="3" 
                                                          onclick="selectEditRating(3)"
                                                          onmouseenter="hoverEditRating(3)">★</span>
                                                    <span class="text-xl cursor-pointer transition-colors edit-star-item ${currentUserFeedback.rating >= 4 ? 'text-yellow-400' : 'text-gray-300'}" 
                                                          data-rating="4" 
                                                          onclick="selectEditRating(4)"
                                                          onmouseenter="hoverEditRating(4)">★</span>
                                                    <span class="text-xl cursor-pointer transition-colors edit-star-item ${currentUserFeedback.rating >= 5 ? 'text-yellow-400' : 'text-gray-300'}" 
                                                          data-rating="5" 
                                                          onclick="selectEditRating(5)"
                                                          onmouseenter="hoverEditRating(5)">★</span>
                                                </div>
                                                <button type="submit" class="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700">
                                                    Cập nhật
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </c:if>
                            </c:if>
                            
                            <!-- Feedback List -->
                            <div class="space-y-6">
                                <c:forEach var="feedback" items="${feedbacks}">
                                    <div class="border-b border-gray-200 pb-6 last:border-b-0">
                                        <div class="flex items-start gap-3">
                                            <!-- Avatar -->
                                            <div class="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center overflow-hidden">
                                                <c:choose>
                                                    <c:when test="${not empty feedback.user.image}">
                                                        <img src="${feedback.user.image}" alt="${feedback.user.fullName}" class="w-full h-full object-cover">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-gray-600 font-semibold">${fn:substring(feedback.user.fullName, 0, 1)}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            
                                            <div class="flex-1">
                                                <!-- User Info -->
                                                <div class="flex items-center gap-2 mb-1">
                                                    <span class="font-semibold text-gray-900">${feedback.user.fullName}</span>
                                                    <c:if test="${not empty feedback.rating}">
                                                        <span class="text-sm text-yellow-600 font-medium">
                                                            ${feedback.rating}/5 ⭐
                                                        </span>
                                                    </c:if>
                                                </div>
                                                
                                                <!-- Timestamp -->
                                                <p class="text-xs text-gray-500 mb-2">
                                                    Bình luận vào <fmt:formatDate value="${feedback.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                                </p>
                                                
                                                <!-- Content -->
                                                <c:if test="${not empty feedback.content}">
                                                    <p class="text-gray-700 mb-3">${feedback.content}</p>
                                                </c:if>
                                                
                                                <!-- Admin Reply (nếu có) -->
                                                <c:if test="${not empty feedback.adminReply}">
                                                    <div class="mt-3 ml-4 pl-4 border-l-2 border-blue-300 bg-blue-50 rounded p-3">
                                                        <div class="flex items-center gap-2 mb-1">
                                                            <span class="font-semibold text-sm text-blue-900">CSKH</span>
                                                        </div>
                                                        <p class="text-xs text-gray-500 mb-1">
                                                            <fmt:formatDate value="${feedback.adminReplyAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                                        </p>
                                                        <p class="text-sm text-gray-700">${feedback.adminReply}</p>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                                
                                <c:if test="${empty feedbacks}">
                                    <p class="text-gray-500 text-center py-8">Chưa có bình luận nào. Hãy là người đầu tiên bình luận!</p>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            <c:set var="isLoggedIn" value="${sessionScope.info != null or sessionScope.user != null}" />
            <c:set var="contextPath" value="${pageContext.request.contextPath}" />
            const maxStock = ${stock > 0 ? stock : 1};
            
            function increaseQuantity() {
                const qtyInput = document.getElementById('quantity');
                let currentQty = parseInt(qtyInput.value) || 1;
                if (currentQty < maxStock) {
                    qtyInput.value = currentQty + 1;
                }
            }
            
            function decreaseQuantity() {
                const qtyInput = document.getElementById('quantity');
                let currentQty = parseInt(qtyInput.value) || 1;
                if (currentQty > 1) {
                    qtyInput.value = currentQty - 1;
                }
            }
            
            function addToCart(productCode, providerId) {
                <c:if test="${!isLoggedIn}">
                    alert('Vui lòng đăng nhập để mua hàng!');
                    window.location.href = '${contextPath}/view/login.jsp';
                    return;
                </c:if>
                
                const quantity = parseInt(document.getElementById('quantity').value) || 1;
                const button = event.target.closest('button');
                const originalText = button.innerHTML;
                
                // Disable button and show loading
                button.disabled = true;
                button.innerHTML = '<i class="bi bi-hourglass-split"></i> Đang thêm...';
                
                // Send request to add to cart
                fetch('${contextPath}/cart/add', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'productCode=' + encodeURIComponent(productCode) + 
                          '&providerId=' + providerId + 
                          '&quantity=' + quantity
                })
                .then(response => {
                    if (response.ok) {
                        return response.json();
                    } else {
                        return response.text().then(text => {
                            throw new Error(text || 'Có lỗi xảy ra');
                        });
                    }
                })
                .then(data => {
                    if (data.success) {
                        button.innerHTML = '<i class="bi bi-check-circle"></i> Đã thêm!';
                        button.classList.add('bg-green-500');
                        setTimeout(() => {
                            button.innerHTML = originalText;
                            button.classList.remove('bg-green-500');
                            button.disabled = false;
                        }, 2000);
                        
                        // Trigger cart update event to refresh badge
                        const cartUpdatedEvent = new Event('cartUpdated');
                        document.dispatchEvent(cartUpdatedEvent);
                        
                        // Cập nhật badge giỏ hàng (sẽ reload sau 1 giây để cập nhật số lượng)
                        setTimeout(() => {
                            window.location.reload();
                        }, 1000);
                        
                        // Show success message
                        if (confirm('Đã thêm sản phẩm vào giỏ hàng!\nBạn có muốn xem giỏ hàng không?')) {
                            window.location.href = '${contextPath}/cart/view';
                        }
                    } else {
                        alert(data.message || 'Có lỗi xảy ra');
                        button.innerHTML = originalText;
                        button.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng: ' + error.message);
                    button.innerHTML = originalText;
                    button.disabled = false;
                });
            }
            
            function buyNow(productCode, providerId) {
                <c:if test="${!isLoggedIn}">
                    alert('Vui lòng đăng nhập để mua hàng!');
                    window.location.href = '${contextPath}/view/login.jsp';
                    return;
                </c:if>
                
                const quantity = parseInt(document.getElementById('quantity').value) || 1;
                const button = event.target.closest('button');
                const originalText = button.innerHTML;
                
                // Disable button and show loading
                button.disabled = true;
                button.innerHTML = '<i class="bi bi-hourglass-split"></i> Đang xử lý...';
                
                // Thêm vào giỏ hàng trước
                fetch('${contextPath}/cart/add', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'productCode=' + encodeURIComponent(productCode) + 
                          '&providerId=' + providerId + 
                          '&quantity=' + quantity
                })
                .then(response => {
                    if (response.ok) {
                        return response.json();
                    } else {
                        return response.text().then(text => {
                            throw new Error(text || 'Có lỗi xảy ra');
                        });
                    }
                })
                .then(data => {
                    if (data.success) {
                        // Thêm thành công, chuyển đến trang giỏ hàng
                        window.location.href = '${contextPath}/cart/view';
                    } else {
                        alert(data.message || 'Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng');
                        button.innerHTML = originalText;
                        button.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi thêm sản phẩm vào giỏ hàng: ' + error.message);
                    button.innerHTML = originalText;
                    button.disabled = false;
                });
            }
            
            let currentSelectedRating = 0;
            let currentEditRating = <c:choose><c:when test="${not empty currentUserFeedback && not empty currentUserFeedback.rating}">${currentUserFeedback.rating}</c:when><c:otherwise>0</c:otherwise></c:choose>;
            
            // Star rating cho form feedback mới
            function hoverRating(rating) {
                const stars = document.querySelectorAll('#starRating .star-item');
                stars.forEach((star, index) => {
                    if (index < rating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        star.classList.remove('text-yellow-400');
                        star.classList.add('text-gray-300');
                    }
                });
            }
            
            function resetStarHover() {
                const stars = document.querySelectorAll('#starRating .star-item');
                stars.forEach((star, index) => {
                    if (index < currentSelectedRating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        star.classList.remove('text-yellow-400');
                        star.classList.add('text-gray-300');
                    }
                });
            }
            
            function selectRating(rating) {
                currentSelectedRating = rating;
                document.getElementById('ratingValue').value = rating;
                const stars = document.querySelectorAll('#starRating .star-item');
                stars.forEach((star, index) => {
                    if (index < rating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        star.classList.remove('text-yellow-400');
                        star.classList.add('text-gray-300');
                    }
                });
            }
            
            // Star rating cho form sửa rating
            function hoverEditRating(rating) {
                const stars = document.querySelectorAll('#editStarRating .edit-star-item');
                stars.forEach((star, index) => {
                    if (index < rating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        if (index >= currentEditRating) {
                            star.classList.remove('text-yellow-400');
                            star.classList.add('text-gray-300');
                        }
                    }
                });
            }
            
            function resetEditStarHover() {
                const stars = document.querySelectorAll('#editStarRating .edit-star-item');
                stars.forEach((star, index) => {
                    if (index < currentEditRating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        star.classList.remove('text-yellow-400');
                        star.classList.add('text-gray-300');
                    }
                });
            }
            
            function selectEditRating(rating) {
                currentEditRating = rating;
                document.getElementById('editRatingValue').value = rating;
                const stars = document.querySelectorAll('#editStarRating .edit-star-item');
                stars.forEach((star, index) => {
                    if (index < rating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        star.classList.remove('text-yellow-400');
                        star.classList.add('text-gray-300');
                    }
                });
            }
            
            // Character counter cho feedback content
            function updateCharCount(textarea, countId) {
                const countElement = document.getElementById(countId);
                if (countElement) {
                    const currentLength = textarea.value.length;
                    const maxLength = textarea.getAttribute('maxlength');
                    countElement.textContent = currentLength;
                    
                    // Đổi màu khi gần giới hạn
                    if (currentLength > maxLength * 0.9) {
                        countElement.classList.add('text-red-600');
                        countElement.classList.remove('text-gray-500');
                    } else {
                        countElement.classList.remove('text-red-600');
                        countElement.classList.add('text-gray-500');
                    }
                }
            }
        </script>
    </body>
</html>
