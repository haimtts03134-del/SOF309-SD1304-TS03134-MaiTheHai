<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập Admin - QRCoffeePoly</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom CSS dành riêng cho Admin -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/css/style.css">
</head>
<body>

<div class="login-container">
    <div class="login-card">
        <div class="login-logo">
            <i class="bi bi-cup-hot-fill me-2"></i>QRCoffee
        </div>
        <div class="login-subtitle">
            Hệ thống quản lý & bán nước chuyên nghiệp
        </div>

        <!-- Hiển thị thông báo thành công / Đăng xuất bàn giao ca -->
        <c:if test="${not empty param.msg}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; font-size: 0.9rem;">
                <i class="bi bi-check-circle-fill me-2"></i> ${param.msg}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Hiển thị thông báo lỗi nếu đăng nhập thất bại -->
        <c:if test="${not empty requestScope.errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show border-0" role="alert" style="border-radius: 10px; font-size: 0.9rem;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> ${requestScope.errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/admin/login" method="post">
            <!-- Email Input -->
            <div class="form-floating mb-3">
                <input type="email" class="form-control" id="email" name="email" 
                       placeholder="name@example.com" value="${requestScope.oldEmail}" required>
                <label for="email"><i class="bi bi-envelope me-2"></i>Địa chỉ Email</label>
            </div>

            <!-- Password Input với Nút Ẩn/Hiện Mật khẩu -->
            <div class="form-floating mb-4 position-relative">
                <input type="password" class="form-control pe-5" id="password" name="password" 
                       placeholder="Mật khẩu" required>
                <label for="password"><i class="bi bi-lock me-2"></i>Mật khẩu</label>
                <button type="button" id="togglePassword" class="btn border-0 position-absolute end-0 top-50 translate-middle-y me-2 text-muted" style="z-index: 10; background: transparent;">
                    <i class="bi bi-eye-slash fs-5" id="toggleIcon"></i>
                </button>
            </div>

            <!-- Submit Button -->
            <button class="btn btn-coffee w-100 py-2 fs-5" type="submit">
                <i class="bi bi-box-arrow-in-right me-2"></i>Đăng Nhập
            </button>
        </form>
    </div>
</div>

<!-- Bootstrap 5 JS Bundle CDN -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script Xử lý Ẩn/Hiện Mật Khẩu -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const togglePassword = document.getElementById("togglePassword");
        const passwordInput = document.getElementById("password");
        const toggleIcon = document.getElementById("toggleIcon");

        if (togglePassword && passwordInput && toggleIcon) {
            togglePassword.addEventListener("click", function () {
                const isPassword = passwordInput.getAttribute("type") === "password";
                passwordInput.setAttribute("type", isPassword ? "text" : "password");
                
                if (isPassword) {
                    toggleIcon.classList.remove("bi-eye-slash");
                    toggleIcon.classList.add("bi-eye");
                } else {
                    toggleIcon.classList.remove("bi-eye");
                    toggleIcon.classList.add("bi-eye-slash");
                }
            });
        }
    });
</script>
</body>
</html>
