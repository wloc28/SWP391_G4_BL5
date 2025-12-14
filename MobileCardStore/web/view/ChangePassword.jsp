<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- Change Password Modal -->
<div class="modal fade" id="changePasswordModal" tabindex="-1" aria-labelledby="changePasswordModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title" id="changePasswordModalLabel">Đổi Mật Khẩu</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="text-center mb-4">
                    <i class="fas fa-key" style="font-size: 48px; color: #ffc107;"></i>
                    <p class="text-muted mt-2">Vui lòng nhập thông tin để đổi mật khẩu</p>
                </div>
                
                <form action="changePassword" method="post" id="changePasswordForm">
                    <div class="mb-3">
                        <label for="oldPassword" class="form-label fw-bold">
                            <i class="fas fa-lock me-2"></i>Mật Khẩu Cũ <span class="text-danger">*</span>
                        </label>
                        <input type="password" 
                               name="oldPassword" 
                               class="form-control form-control-lg" 
                               id="oldPassword" 
                               placeholder="Nhập mật khẩu cũ" 
                               required
                               autocomplete="current-password">
                    </div>
                    
                    <div class="mb-3">
                        <label for="newPassword" class="form-label fw-bold">
                            <i class="fas fa-key me-2"></i>Mật Khẩu Mới <span class="text-danger">*</span>
                        </label>
                        <input type="password" 
                               name="newPassword" 
                               class="form-control form-control-lg" 
                               id="newPassword" 
                               placeholder="Nhập mật khẩu mới" 
                               pattern="^(?=.*[A-Za-z])(?=.*\d).{6,}$"
                               title="Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số"
                               required
                               autocomplete="new-password">
                        <div class="form-text">
                            <i class="fas fa-info-circle me-1"></i>Mật khẩu phải có ít nhất 6 ký tự, bao gồm chữ và số
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label fw-bold">
                            <i class="fas fa-check-double me-2"></i>Xác Nhận Mật Khẩu Mới <span class="text-danger">*</span>
                        </label>
                        <input type="password" 
                               name="confirmPassword" 
                               class="form-control form-control-lg" 
                               id="confirmPassword" 
                               placeholder="Nhập lại mật khẩu mới" 
                               required
                               autocomplete="new-password">
                        <div id="passwordMatchError" class="text-danger mt-1"></div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times me-2"></i>Hủy
                </button>
                <button type="submit" form="changePasswordForm" class="btn btn-warning">
                    <i class="fas fa-key me-2"></i>Đổi Mật Khẩu
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    // Validate password match
    document.getElementById('confirmPassword')?.addEventListener('input', function() {
        var newPassword = document.getElementById('newPassword').value;
        var confirmPassword = this.value;
        var errorDiv = document.getElementById('passwordMatchError');
        
        if (confirmPassword && newPassword !== confirmPassword) {
            errorDiv.textContent = 'Mật khẩu xác nhận không khớp!';
        } else {
            errorDiv.textContent = '';
        }
    });
</script>
