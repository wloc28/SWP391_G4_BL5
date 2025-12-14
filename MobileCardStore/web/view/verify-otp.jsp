<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Xác thực Email - OTP</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-5">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h3 class="text-center mb-0">Xác thực Email</h3>
                        </div>
                        <div class="card-body">
                            <c:if test="${not empty requestScope.error}">
                                <div class="alert alert-danger" role="alert">
                                    ${requestScope.error}
                                </div>
                            </c:if>
                            
                            <c:if test="${not empty requestScope.success}">
                                <div class="alert alert-success" role="alert">
                                    ${requestScope.success}
                                </div>
                            </c:if>
                            
                            <c:if test="${sessionScope.registerEmail == null}">
                                <div class="alert alert-warning">
                                    <p>Không tìm thấy thông tin đăng ký. Vui lòng đăng ký lại.</p>
                                    <a href="${pageContext.request.contextPath}/view/register.jsp" class="btn btn-primary">Đăng ký lại</a>
                                </div>
                            </c:if>
                            
                            <c:if test="${sessionScope.registerEmail != null}">
                                <div class="alert alert-info">
                                    <p><strong>Mã OTP đã được gửi đến email:</strong></p>
                                    <p class="mb-0">${sessionScope.registerEmail}</p>
                                    <p class="mt-2 mb-0"><small>Vui lòng kiểm tra hộp thư và nhập mã OTP 6 chữ số.</small></p>
                                    <p class="mb-0"><small>Mã OTP có hiệu lực trong <strong>5 phút</strong>.</small></p>
                                </div>
                                
                                <form action="register" method="post">
                                    <input type="hidden" name="action" value="verifyOTP"/>
                                    
                                    <div class="mb-3">
                                        <label for="otp" class="form-label">Nhập mã OTP</label>
                                        <input type="text" 
                                               name="otp" 
                                               class="form-control form-control-lg text-center" 
                                               id="otp" 
                                               placeholder="000000" 
                                               maxlength="6"
                                               pattern="[0-9]{6}"
                                               required
                                               autocomplete="off">
                                        <div class="form-text">Nhập 6 chữ số từ email của bạn</div>
                                    </div>
                                    
                                    <div class="d-grid gap-2 mb-3">
                                        <button type="submit" class="btn btn-primary btn-lg">Xác thực</button>
                                    </div>
                                    
                                    <div class="text-center">
                                        <p class="mb-2">Không nhận được mã OTP?</p>
                                        <form action="register" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="sendOTP"/>
                                            <button type="submit" class="btn btn-link">Gửi lại mã OTP</button>
                                        </form>
                                    </div>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            // Auto focus vào ô OTP
            document.getElementById('otp')?.focus();
            
            // Auto submit khi nhập đủ 6 số
            document.getElementById('otp')?.addEventListener('input', function(e) {
                if (this.value.length === 6) {
                    // Có thể tự động submit hoặc chỉ validate
                }
            });
        </script>
    </body>
</html>




