<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Lấy thông tin đơn hàng vừa đặt từ database
    String orderIdStr = request.getParameter("orderId");
    if (orderIdStr != null) {
        try {
            int orderId = Integer.parseInt(orderIdStr);
            dao.OrderDao orderDao = new dao.OrderDao();
            entity.Order order = orderDao.findById(orderId);
            request.setAttribute("order", order);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Món Thành Công - QRCoffeePoly</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        :root {
            --primary-color: #00704a;       /* Coffee Shop Green */
            --accent-color: #b5835a;       /* Coffee Shop Gold/Bronze */
            --bg-color: #f8f6f2;           /* Light Warm Cream background */
            --glass-bg: #ffffff;           /* Clean white card bg */
            --glass-border: rgba(45, 26, 18, 0.12);
            --glass-shadow: rgba(45, 26, 18, 0.05);
            --text-main: #2d1a12;          /* Espresso Dark Brown for supreme contrast */
            --text-muted: #6e625e;         /* Chestnut Muted Brown */
            --overlay-color: linear-gradient(180deg, rgba(248, 246, 242, 0.85) 0%, rgba(248, 246, 242, 0.96) 100%);
        }

        body {
            font-family: 'Plus Jakarta Sans', 'Outfit', sans-serif;
            background-color: var(--bg-color);
            background-image: url('https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=1600');
            background-repeat: no-repeat;
            background-position: center center;
            background-attachment: fixed;
            background-size: cover;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
            padding: 24px 0;
        }

        /* Video Background */
        .video-background {
            position: fixed;
            right: 0;
            bottom: 0;
            min-width: 100%;
            min-height: 100%;
            width: auto;
            height: auto;
            z-index: -100;
            object-fit: cover;
            opacity: 0.18;
            filter: saturate(0.8) contrast(1.1);
        }

        /* Background overlay */
        .bg-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--overlay-color);
            z-index: -99;
        }

        .glass-panel {
            background: var(--glass-bg);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 28px;
            box-shadow: 0 15px 50px var(--glass-shadow);
            width: 100%;
            max-width: 550px;
            overflow: hidden;
            animation: slideUp 0.6s cubic-bezier(0.165, 0.84, 0.44, 1);
            transition: background 0.4s ease, border 0.4s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .receipt-header {
            padding: 35px 35px 25px 35px;
            border-bottom: 2px dashed var(--glass-border);
            text-align: center;
            position: relative;
        }

        /* Half-circles on left and right borders of dashed line */
        .receipt-header::before, .receipt-header::after {
            content: '';
            position: absolute;
            bottom: -10px;
            width: 20px;
            height: 20px;
            background-color: var(--bg-color);
            border-radius: 50%;
            z-index: 10;
            transition: background-color 0.4s ease;
        }
        .receipt-header::before {
            left: -10px;
        }
        .receipt-header::after {
            right: -10px;
        }

        .success-icon-wrapper {
            width: 72px;
            height: 72px;
            background: rgba(0, 112, 74, 0.1);
            border: 1px solid rgba(0, 112, 74, 0.25);
            color: var(--primary-color);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px auto;
            font-size: 32px;
            box-shadow: 0 0 20px rgba(0, 112, 74, 0.1);
        }

        .receipt-body {
            padding: 35px;
        }

        .receipt-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 0.95rem;
        }

        .receipt-label {
            color: var(--text-muted);
        }

        .receipt-value {
            font-weight: 600;
            color: var(--text-main);
            text-align: right;
        }

        .btn-coffee {
            background: var(--primary-color);
            border: none;
            color: #fff !important;
            font-weight: 600;
            border-radius: 50px;
            padding: 12px 24px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 112, 74, 0.25);
        }

        .btn-coffee:hover {
            background: #00704a;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 112, 74, 0.4);
        }
    </style>
</head>
<body>

    <!-- Video Nền Loop -->
    <video class="video-background" autoplay muted loop playsinline>
        <source src="https://assets.mixkit.co/videos/preview/mixkit-pouring-hot-coffee-into-a-cup-42283-large.mp4" type="video/mp4">
    </video>
    <div class="bg-overlay"></div>

    <div class="container d-flex justify-content-center align-items-center">
        <div class="glass-panel shadow">
            
            <c:choose>
                <c:when test="${not empty order}">
                    <!-- Receipt Header -->
                    <div class="receipt-header">
                        <div class="success-icon-wrapper">
                            <i class="bi bi-patch-check-fill"></i>
                        </div>
                        <h4 class="fw-bold m-0" style="color: var(--text-main);">ĐẶT MÓN THÀNH CÔNG</h4>
                        <p class="text-success small mb-0 mt-1 fw-bold">Cảm ơn bạn đã tin dùng dịch vụ của chúng tôi!</p>
                    </div>

                    <!-- Receipt Body -->
                    <div class="receipt-body">
                        <%
                            entity.Order o = (entity.Order) request.getAttribute("order");
                            String custName = "";
                            String custPhone = "";
                            int custPoints = 0;
                            if (o != null && o.getCustomer() != null) {
                                try {
                                    custName = o.getCustomer().getHoTen();
                                } catch (Throwable t) {
                                    custName = "Không thể đọc tên";
                                }
                                try {
                                    custPhone = o.getCustomer().getSoDienThoai();
                                } catch (Throwable t) {
                                    custPhone = "Không thể đọc SĐT";
                                }
                                try {
                                    custPoints = o.getCustomer().getDiemTichLuy();
                                } catch (Throwable t) {
                                    custPoints = 0;
                                }
                            }
                            pageContext.setAttribute("custName", custName);
                            pageContext.setAttribute("custPhone", custPhone);
                            pageContext.setAttribute("custPoints", custPoints);
                        %>
                        
                        <div class="receipt-row">
                            <span class="receipt-label">Mã hóa đơn:</span>
                            <span class="receipt-value text-success">HD${order.maHoaDon}</span>
                        </div>
                        <div class="receipt-row">
                            <span class="receipt-label">Khách hàng:</span>
                            <span class="receipt-value">${custName}</span>
                        </div>
                        <div class="receipt-row">
                            <span class="receipt-label">Số điện thoại:</span>
                            <span class="receipt-value">${custPhone}</span>
                        </div>
                        <div class="receipt-row">
                            <span class="receipt-label">Hình thức:</span>
                            <span class="receipt-value fw-semibold text-dark">
                                <c:choose>
                                    <c:when test="${order.loaiHoaDon == 'TaiCho'}">
                                        <c:choose>
                                            <c:when test="${not empty order.table}">
                                                Tại chỗ (${order.table.tenBan})
                                            </c:when>
                                            <c:otherwise>
                                                Tại quán (Tự chọn bàn)
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        Mang về
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="receipt-row">
                            <span class="receipt-label">Thời gian:</span>
                            <span class="receipt-value">
                                <fmt:formatDate value="${order.ngayTao}" pattern="HH:mm - dd/MM/yyyy"/>
                            </span>
                        </div>
                        
                        <c:if test="${not empty order.ghiChu}">
                            <div class="receipt-row">
                                <span class="receipt-label">Ghi chú:</span>
                                <span class="receipt-value text-wrap fst-italic">"${order.ghiChu}"</span>
                            </div>
                        </c:if>

                        <hr class="border-light border-opacity-10 my-4" style="border-color: var(--glass-border) !important;">

                        <h6 class="fw-bold mb-3" style="color: var(--text-main);"><i class="bi bi-bag-check-fill text-success me-2"></i>Danh Sách Món Đã Đặt</h6>
                        
                        <!-- Loop order details -->
                        <div class="mb-4">
                            <c:forEach var="detail" items="${order.orderDetails}">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div style="max-width: 70%;">
                                        <span class="fw-semibold" style="color: var(--text-main);">${detail.drink.tenSanPham}</span>
                                        <span class="text-muted small d-block">${detail.soLuong} x <fmt:formatNumber value="${detail.donGia}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                    </div>
                                    <span class="fw-bold text-success">
                                        <fmt:formatNumber value="${detail.soLuong * detail.donGia}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </div>
                            </c:forEach>
                        </div>

                        <hr class="border-light border-opacity-10 my-4" style="border-color: var(--glass-border) !important;">

                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <span class="fs-5 fw-bold" style="color: var(--text-main);">TỔNG CỘNG:</span>
                            <span class="fs-3 fw-bold text-success">
                                <fmt:formatNumber value="${order.tongTien}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                        </div>

                        <!-- Điểm tích lũy hiện tại của khách hàng -->
                        <div class="alert bg-success bg-opacity-10 border-0 text-success text-center rounded-pill py-2.5 mb-4 fw-bold">
                            <i class="bi bi-star-fill me-1"></i>
                            Tích lũy thêm: <fmt:formatNumber value="${order.tongTien / 10000}" maxFractionDigits="0"/> điểm. Tổng điểm thành viên: ${custPoints}
                        </div>

                        <c:set var="targetTableParam" value="${not empty order.table ? order.table.maBan : sessionScope.sessionTableId}" />
                        <div class="text-center">
                            <a href="${pageContext.request.contextPath}/menu${not empty targetTableParam ? '?tableId=' : ''}${not empty targetTableParam ? targetTableParam : ''}" class="btn btn-coffee w-100 py-3 rounded-pill" onclick="clearLocalCart()">
                                <i class="bi bi-cart-plus-fill me-2"></i> Tiếp Tục Đặt Món
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Receipt Header if Order Null -->
                    <div class="receipt-body text-center py-5">
                        <i class="bi bi-x-circle-fill text-danger fs-1 mb-3"></i>
                        <h4 class="fw-bold" style="color: var(--text-main);">Không Tìm Thấy Đơn Hàng</h4>
                        <p class="text-muted mb-4">Hóa đơn này không tồn tại hoặc đã bị xóa khỏi hệ thống.</p>
                        <c:set var="targetTableParam" value="${sessionScope.sessionTableId}" />
                        <a href="${pageContext.request.contextPath}/menu${not empty targetTableParam ? '?tableId=' : ''}${not empty targetTableParam ? targetTableParam : ''}" class="btn btn-coffee px-4 rounded-pill">
                            Tiếp Tục Đặt Món
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>

    <script>
        // Xóa sạch giỏ hàng tạm và thông tin khách hàng sau khi đặt món thành công
        function clearLocalCart() {
            try {
                sessionStorage.removeItem("coffee_cart");
                sessionStorage.removeItem("coffee_cart_table_id");
                localStorage.removeItem("coffee_cart");
                localStorage.removeItem("coffee_cart_table_id");
                localStorage.removeItem("coffee_table_id");
                localStorage.removeItem("coffee_cust_name");
                localStorage.removeItem("coffee_cust_phone");
            } catch (e) {
                console.warn("Storage cleanup error:", e);
            }
        }
        document.addEventListener("DOMContentLoaded", clearLocalCart);
    </script>
</body>
</html>
