<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                                <c:when test="${not empty product.imageUrl}">
                                    <img src="${product.imageUrl}" class="w-full rounded-lg border border-gray-200 bg-gray-100" 
                                         alt="${product.productName}" 
                                         onerror="this.src='https://via.placeholder.com/500x500?text=No+Image'">
                                </c:when>
                                <c:otherwise>
                                    <img src="https://via.placeholder.com/500x500?text=No+Image" 
                                         class="w-full rounded-lg border border-gray-200 bg-gray-100" alt="${product.productName}">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!-- Product Information -->
                        <div>
                            <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-4">
                                <h1 class="text-xl font-bold text-gray-900 mb-2">${product.productName}</h1>
                                
                                <!-- Provider Info -->
                                <div class="flex gap-2 mb-2">
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">${product.provider.providerName}</span>
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                        <c:choose>
                                            <c:when test="${product.provider.providerType == 'TEL'}">Thẻ điện thoại</c:when>
                                            <c:when test="${product.provider.providerType == 'GAME'}">Thẻ game</c:when>
                                            <c:otherwise>${product.provider.providerType}</c:otherwise>
                                        </c:choose>
                                    </span>
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
                                                <span class="text-gray-900">#${product.productId}</span>
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
                                
                                <!-- Action Buttons -->
                                <div class="flex gap-2">
                                    <c:choose>
                                        <c:when test="${sessionScope.info == null and sessionScope.user == null}">
                                            <button onclick="alert('Vui lòng đăng nhập để mua hàng!'); window.location.href='${pageContext.request.contextPath}/view/login.jsp';" 
                                                    class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                Đăng nhập để mua hàng
                                            </button>
                                        </c:when>
                                        <c:when test="${stock > 0 && product.status == 'ACTIVE'}">
                                            <button onclick="addToCart(${product.productId})" 
                                                    class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                Thêm vào giỏ hàng
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
                                             onclick="window.location.href='${pageContext.request.contextPath}/product-detail?id=${relatedProduct.productId}'">
                                            <!-- Product Image -->
                                            <div class="aspect-square bg-white">
                                                <c:choose>
                                                    <c:when test="${not empty relatedProduct.imageUrl}">
                                                        <img src="${relatedProduct.imageUrl}" 
                                                             class="w-full h-full object-cover" 
                                                             alt="${relatedProduct.productName}"
                                                             onerror="this.src='https://via.placeholder.com/150x150?text=No+Image'">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="https://via.placeholder.com/150x150?text=No+Image" 
                                                             class="w-full h-full object-cover" 
                                                             alt="${relatedProduct.productName}">
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
                                                        ${relatedProduct.provider.providerName}
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
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            <c:set var="isLoggedIn" value="${sessionScope.info != null or sessionScope.user != null}" />
            function addToCart(productId) {
                <c:choose>
                    <c:when test="${!isLoggedIn}">
                        alert('Vui lòng đăng nhập để mua hàng!');
                        window.location.href = '${pageContext.request.contextPath}/view/login.jsp';
                        return;
                    </c:when>
                    <c:otherwise>
                // TODO: Implement add to cart functionality
                alert('Tính năng thêm vào giỏ hàng sẽ được triển khai sau. Product ID: ' + productId);
                // You can implement AJAX call here to add product to cart
                // Example:
                // fetch('add-to-cart', {
                //     method: 'POST',
                //     headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                //     body: 'productId=' + productId
                // })
                    </c:otherwise>
                </c:choose>
            }
        </script>
    </body>
</html>
