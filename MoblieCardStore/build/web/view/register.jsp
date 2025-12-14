<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Đăng Ký</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h2 class="text-center mb-0">Đăng Ký Tài Khoản</h2>
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
                            
                            <form action="register" method="post" id="registerForm">
                                <div class="mb-3">
                                    <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
                                    <input type="email" 
                                           name="email" 
                                           class="form-control" 
                                           id="email" 
                                           placeholder="Nhập email của bạn" 
                                           required
                                           value="${param.email}">
                                    <div class="form-text">Email sẽ được dùng để đăng nhập và xác thực</div>
                                    <div id="emailError" class="text-danger"></div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="username" class="form-label">Username</label>
                                    <input type="text" 
                                           name="username" 
                                           class="form-control" 
                                           id="username" 
                                           placeholder="Nhập username (tùy chọn)"
                                           value="${param.username}">
                                    <div class="form-text">Nếu để trống, username sẽ được tạo từ email</div>
                                    <div id="usernameError" class="text-danger"></div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="password" class="form-label">Mật khẩu <span class="text-danger">*</span></label>
                                    <input type="password" 
                                           name="password" 
                                           class="form-control" 
                                           id="password" 
                                           placeholder="Nhập mật khẩu" 
                                           pattern="^(?=.*[A-Za-z])(?=.*\d).{6,}$"
                                           title="Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số"
                                           required>
                                    <div class="form-text">Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số</div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="fullname" class="form-label">Họ và Tên <span class="text-danger">*</span></label>
                                    <input type="text" 
                                           name="fullname" 
                                           class="form-control" 
                                           id="fullname" 
                                           placeholder="Nhập họ và tên" 
                                           pattern="[^\d]+"
                                           title="Họ tên không được chứa số"
                                           required
                                           value="${param.fullname}">
                                </div>
                                
                                <div class="mb-3">
                                    <label for="mobile" class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                                    <input type="tel" 
                                           name="mobile" 
                                           class="form-control" 
                                           id="mobile" 
                                           placeholder="Nhập số điện thoại" 
                                           pattern="[0-9]*"
                                           title="Chỉ nhập số"
                                           required
                                           value="${param.mobile}">
                                </div>
                                
                                <div class="d-grid mb-3">
                                    <button type="submit" class="btn btn-primary btn-lg">Đăng Ký</button>
                                </div>
                                
                                <div class="text-center">
                                    <p class="mb-0">Đã có tài khoản? <a href="${pageContext.request.contextPath}/view/login.jsp">Đăng nhập ngay</a></p>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            // Kiểm tra email đã tồn tại
            document.getElementById('email')?.addEventListener('blur', function() {
                var email = this.value.trim();
                var emailError = document.getElementById('emailError');
                var submitButton = document.getElementById('registerForm').querySelector('button[type="submit"]');
                
                // Clear previous error
                emailError.textContent = '';
                submitButton.disabled = false;
                
                if (email) {
                    // Validate email format first
                    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(email)) {
                        emailError.textContent = 'Email không hợp lệ!';
                        submitButton.disabled = true;
                        return;
                    }
                    
                    // Encode email for URL
                    var encodedEmail = encodeURIComponent(email);
                    
                    console.log('Checking email: ' + email);
                    
                    fetch('registercheck?email=' + encodedEmail)
                        .then(response => {
                            console.log('Response status: ' + response.status);
                            return response.text();
                        })
                        .then(data => {
                            console.log('Response data: [' + data + ']');
                            data = data.trim();
                            
                            if (data === '1') {
                                emailError.textContent = 'Email này đã được sử dụng!';
                                submitButton.disabled = true;
                            } else if (data === '0') {
                                emailError.textContent = '';
                                submitButton.disabled = false;
                            } else {
                                console.error('Unexpected response: ' + data);
                                emailError.textContent = 'Lỗi kiểm tra email. Vui lòng thử lại.';
                            }
                        })
                        .catch(error => {
                            console.error('Error checking email:', error);
                            emailError.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
                        });
                }
            });
        </script>
    </body>
</html>

