<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QRCoffeePoly - Trang Quản Trị</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom CSS Dành riêng cho Admin -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/css/style.css">
</head>
<body>

<div id="wrapper">
    <!-- Thanh điều hướng Sidebar -->
    <nav id="sidebar">
        <div class="sidebar-header text-center py-4">
            <h3 class="fw-bold mb-1" style="color: var(--secondary-gold); letter-spacing: 0.5px;">QRCoffeePoly</h3>
            <small class="text-white-50" style="font-size: 0.78rem;">Hệ thống quản lý quán Cà Phê</small>
        </div>

        <!-- Khối Thông Tin Tài Khoản Đang Đăng Nhập bên Sidebar -->
        <div class="px-3 mb-4">
            <div class="user-sidebar-box rounded-3 d-flex align-items-center" 
                 style="background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.14); padding: 12px 14px; border-radius: 14px; gap: 12px;">
                <c:set var="sidebarAvatar" value="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100" />
                <c:if test="${not empty sessionScope.adminAvatar}">
                    <c:choose>
                        <c:when test="${sessionScope.adminAvatar.startsWith('http') || sessionScope.adminAvatar.startsWith('data:') || sessionScope.adminAvatar.startsWith('/')}">
                            <c:set var="sidebarAvatar" value="${sessionScope.adminAvatar}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="sidebarAvatar" value="${pageContext.request.contextPath}/admin/images/${sessionScope.adminAvatar}" />
                        </c:otherwise>
                    </c:choose>
                </c:if>
                <img src="${sidebarAvatar}" alt="Avatar Admin" class="rounded-circle border border-2 border-warning shadow-sm flex-shrink-0" style="width: 44px; height: 44px; object-fit: cover;" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100';">
                <div class="overflow-hidden flex-grow-1" style="line-height: 1.3;">
                    <small class="d-block text-warning opacity-75 fw-semibold mb-1" style="font-size: 0.72rem; letter-spacing: 0.3px;">Xin chào,</small>
                    <span class="fw-bold text-white text-truncate d-block" style="font-size: 0.92rem;" title="${sessionScope.adminName}">
                        <c:choose>
                            <c:when test="${not empty sessionScope.adminName}">${sessionScope.adminName}</c:when>
                            <c:otherwise>Quản trị viên</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </div>
        </div>

        <ul class="list-unstyled components">
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/dashboard' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/dashboard">
                    <i class="bi bi-speedometer2"></i> Bảng điều khiển
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/drinks' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/drinks">
                    <i class="bi bi-cup-hot"></i> Quản lý thức uống
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/tables' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/tables">
                    <i class="bi bi-grid-3x3-gap"></i> Quản lý số bàn
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/employees' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/employees">
                    <i class="bi bi-people"></i> Quản lý nhân viên
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/attendance' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/attendance">
                    <i class="bi bi-calendar-check"></i> Chấm công & Ca làm
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/customers' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/customers">
                    <i class="bi bi-person-badge"></i> Quản lý khách hàng
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/revenue' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/revenue">
                    <i class="bi bi-cash-coin"></i> Thống kê doanh thu
                </a>
            </li>
            <li class="${requestScope['javax.servlet.forward.servlet_path'] == '/admin/invoices' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/invoices">
                    <i class="bi bi-receipt"></i> Quản lý hóa đơn
                </a>
            </li>
            <li class="mt-4">
                <a href="${pageContext.request.contextPath}/admin/logout?scope=admin" class="text-danger">
                    <i class="bi bi-box-arrow-right text-danger"></i> Đăng xuất
                </a>
            </li>
        </ul>
    </nav>

    <!-- Khối nội dung chính bên phải -->
    <div id="content">

