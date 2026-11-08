<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Bảo vệ: Nếu người dùng truy cập trực tiếp file JSP này thay vì qua Servlet /menu
    if (request.getAttribute("drinks") == null) {
        response.sendRedirect(request.getContextPath() + "/menu");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Đơn - QRCoffeePoly</title>
    <!-- Google Fonts: Outfit & Plus Jakarta Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        /* Định nghĩa biến màu sắc: Giao diện sáng ấm áp (Light Warm Cream Theme) */
        :root {
            --primary-color: #00704a;       /* Xanh lá đậm ấm áp */
            --primary-hover: #1e3932;      /* Xanh lá rừng sâu */
            --accent-color: #b5835a;       /* Nâu đồng cà phê */
            --bg-color: #f8f6f2;           /* Nền kem sáng ấm */
            --card-bg: #ffffff;            /* Nền thẻ trắng tinh */
            --card-text: #2d1a12;          /* Chữ nâu Espresso đậm - Cực kỳ dễ đọc */
            --text-muted: #6e625e;         /* Chữ phụ màu nâu hạt dẻ */
            --border-color: rgba(45, 26, 18, 0.12);
            --overlay-color: linear-gradient(180deg, rgba(248, 246, 242, 0.85) 0%, rgba(248, 246, 242, 0.96) 100%);
            --shadow-color: rgba(45, 26, 18, 0.06);
            --header-bg: rgba(248, 246, 242, 0.9);
            --panel-bg: #ffffff;
            --input-bg: rgba(45, 26, 18, 0.04);
            --pill-bg: rgba(45, 26, 18, 0.04);
            --pill-text: #6e625e;
            --badge-bg: #00704a;
            --badge-text: #ffffff;
        }

        body {
            font-family: 'Plus Jakarta Sans', 'Outfit', sans-serif;
            background-color: var(--bg-color);
            background-image: url('https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=1600');
            background-repeat: no-repeat;
            background-position: center center;
            background-attachment: fixed;
            background-size: cover;
            color: var(--card-text);
            min-height: 100vh;
            overflow-x: hidden;
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
            opacity: 0.18; /* Độ mờ video nhẹ nhàng */
            filter: saturate(0.8) contrast(1.05);
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

        /* Glassmorphism Classes */
        .glass-header {
            background: var(--header-bg);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--border-color);
            z-index: 1000;
            position: sticky;
            top: 0;
        }

        .glass-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            box-shadow: 0 6px 18px var(--shadow-color);
            transition: transform 0.3s cubic-bezier(0.165, 0.84, 0.44, 1), 
                        border-color 0.3s ease, 
                        box-shadow 0.3s ease;
            overflow: hidden;
            height: 100%;
        }

        .glass-card:hover {
            transform: translateY(-6px);
            border-color: var(--primary-color);
            box-shadow: 0 12px 24px rgba(45, 26, 18, 0.12);
        }

        .glass-panel {
            background: var(--panel-bg);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            box-shadow: 0 8px 24px var(--shadow-color);
        }

        /* Thẻ tính toán giỏ hàng bên phải sticky */
        .sticky-cart-panel {
            position: sticky;
            top: 100px;
            max-height: calc(100vh - 140px);
            overflow-y: auto;
        }

        /* Drink Image Hover zoom */
        .drink-img-wrapper {
            position: relative;
            overflow: hidden;
            height: 200px;
        }

        .drink-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }

        .glass-card:hover .drink-img {
            transform: scale(1.06);
        }

        /* Buttons & Badges */
        .btn-coffee {
            background: var(--primary-color);
            border: none;
            color: #fff !important;
            font-weight: 600;
            border-radius: 50px;
            padding: 10px 22px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0, 112, 74, 0.15);
        }

        .btn-coffee:hover {
            background: var(--primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(0, 112, 74, 0.25);
        }

        .category-pill {
            background: var(--pill-bg);
            border: 1px solid var(--border-color);
            color: var(--pill-text);
            border-radius: 50px;
            padding: 8px 18px;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            white-space: nowrap;
            font-size: 0.9rem;
        }

        .category-pill:hover, .category-pill.active {
            background: var(--primary-color);
            color: #ffffff;
            border-color: var(--primary-color);
            box-shadow: 0 4px 12px rgba(0, 112, 74, 0.2);
        }

        /* Form Inputs style */
        .glass-input {
            background: var(--input-bg);
            border: 1px solid var(--border-color);
            color: var(--card-text);
            border-radius: 12px;
            padding: 12px 16px;
            transition: all 0.3s ease;
        }

        .glass-input:focus {
            background: #ffffff;
            border-color: var(--primary-color);
            color: var(--card-text);
            box-shadow: 0 0 8px rgba(0, 112, 74, 0.1);
            outline: none;
        }

        /* Dropdown Select Option styling */
        select.glass-input option {
            background-color: #ffffff;
            color: var(--card-text);
        }

        .glass-input::placeholder {
            color: #9e928e;
        }

        .brand-title {
            color: var(--card-text);
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .brand-logo-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            box-shadow: 0 4px 8px rgba(0, 112, 74, 0.2);
        }
    </style>
</head>
<body>

    <!-- Video Nền Loop -->
    <video class="video-background" autoplay muted loop playsinline id="bgVideo">
        <source src="https://assets.mixkit.co/videos/preview/mixkit-pouring-hot-coffee-into-a-cup-42283-large.mp4" type="video/mp4">
    </video>
    <div class="bg-overlay"></div>

    <!-- Thanh tiêu đề Glassmorphism (Loại bỏ ô chọn bàn) -->
    <header class="glass-header py-3 mb-4 shadow-sm">
        <div class="container d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-3">
                <div class="brand-logo-circle">
                    <i class="bi bi-cup-hot"></i>
                </div>
                <div>
                    <h1 class="h4 m-0 brand-title">QRCoffeePoly</h1>
                    <small class="text-success fw-bold">Coffee and Chill</small>
                </div>
            </div>
            
            <div>
                <!-- Chỉ hiển thị trạng thái cửa hàng -->
                <span class="badge bg-success text-white px-3 py-2 fs-6 rounded-pill">
                    <i class="bi bi-clock-fill me-1"></i> Open: 7:00 - 22:00
                </span>
            </div>
        </div>
    </header>

    <div class="container pb-5">
        <!-- Báo lỗi nếu có -->
        <c:if test="${not empty sessionScope.orderError}">
            <div class="alert alert-danger alert-dismissible fade show border-0 glass-panel shadow mb-4 text-danger" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <strong>Lỗi đặt món!</strong> ${sessionScope.orderError}
                <% session.removeAttribute("orderError"); %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="row g-4">
            <!-- CỘT TRÁI: Thanh tìm kiếm, các bộ lọc và danh sách nước uống -->
            <div class="col-12 col-lg-8">
                <!-- Khối tìm kiếm & lọc danh mục -->
                <div class="glass-panel p-4 mb-4">
                    <div class="row g-3 align-items-center">
                        <!-- Tìm kiếm -->
                        <div class="col-12 col-md-7">
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-0 text-muted" id="search-addon">
                                    <i class="bi bi-search"></i>
                                </span>
                                <input type="text" class="form-control glass-input border-0 ps-0" 
                                       id="searchInput" placeholder="Tìm kiếm đồ uống yêu thích của bạn..." aria-describedby="search-addon"
                                       onkeyup="filterDrinks()">
                            </div>
                        </div>
                        <!-- Sắp xếp theo giá -->
                        <div class="col-12 col-md-5">
                            <select class="form-select glass-input border-0" id="sortSelect" onchange="filterDrinks()">
                                <option value="">Sắp xếp mặc định</option>
                                <option value="asc">Giá: Thấp đến Cao</option>
                                <option value="desc">Giá: Cao đến Thấp</option>
                            </select>
                        </div>
                    </div>

                    <!-- Thanh trượt Danh mục -->
                    <div class="d-flex gap-2 overflow-x-auto mt-3 py-2 scroll-x-hidden">
                        <div class="category-pill active" data-category="all" onclick="selectCategory('all', this)">Tất cả</div>
                        <c:forEach var="cat" items="${categories}">
                            <div class="category-pill" data-category="${cat.maDanhMuc}" onclick="selectCategory('${cat.maDanhMuc}', this)">
                                ${cat.tenDanhMuc}
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- Tiêu đề thực đơn -->
                <div class="row mb-3">
                    <div class="col-12 d-flex justify-content-between align-items-center">
                        <h3 class="fw-bold m-0 brand-title"><i class="bi bi-cup-straw text-success me-2"></i>Thực Đơn Đồ Uống</h3>
                        <span class="text-muted fw-semibold" id="drinksCountText">Đang hiển thị: ${drinks.size()} món</span>
                    </div>
                </div>

                <!-- Lưới món ăn (Grid) -->
                <div class="row g-3" id="drinksGrid">
                    <c:forEach var="drink" items="${drinks}">
                        <div class="col-12 col-sm-6 col-md-6 col-lg-4 drink-card-item" 
                             data-id="${drink.maSanPham}" 
                             data-name="${drink.tenSanPham}" 
                             data-price="${drink.giaCoBan}" 
                             data-category="${drink.category.maDanhMuc}">
                            <div class="glass-card d-flex flex-column">
                                <div class="drink-img-wrapper">
                                    <c:choose>
                                        <c:when test="${not empty drink.hinhAnh}">
                                            <c:set var="imgUrl" value="${drink.hinhAnh}" />
                                            <c:if test="${!drink.hinhAnh.startsWith('http') && !drink.hinhAnh.startsWith('data:') && !drink.hinhAnh.startsWith('/')}">
                                                <c:set var="imgUrl" value="${pageContext.request.contextPath}/admin/images/${drink.hinhAnh}" />
                                            </c:if>
                                            <img src="${imgUrl}" class="drink-img" alt="${drink.tenSanPham}" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/${drink.hinhAnh}'; if(this.naturalWidth===0){this.src='https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500';}">
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500" />
                                            <img src="${imgUrl}" class="drink-img" alt="${drink.tenSanPham}">
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="badge bg-dark bg-opacity-75 text-warning px-2.5 py-1.5 fs-7 position-absolute top-3 end-3 rounded-pill border border-warning border-opacity-25">
                                        ${drink.category.tenDanhMuc}
                                    </span>
                                </div>
                                <div class="p-3 flex-grow-1 d-flex flex-column justify-content-between">
                                    <div>
                                        <h5 class="fw-bold mb-1 text-truncate-2" style="color: var(--card-text);">${drink.tenSanPham}</h5>
                                        <p class="text-muted small text-truncate-2 mb-3" style="min-height: 38px;">${drink.moTa}</p>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mt-auto">
                                        <span class="fs-5 fw-bold text-success">
                                            <fmt:formatNumber value="${drink.giaCoBan}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </span>
                                        <button type="button" 
                                                data-id="${drink.maSanPham}" 
                                                data-name="<c:out value='${drink.tenSanPham}' escapeXml='true'/>" 
                                                data-price="${drink.giaCoBan}" 
                                                data-img="<c:out value='${imgUrl}' escapeXml='true'/>" 
                                                onclick="addToCartFromBtn(this, event)" 
                                                class="btn btn-coffee btn-sm px-3 rounded-pill">
                                            <i class="bi bi-plus-lg me-1" style="pointer-events: none;"></i><span style="pointer-events: none;">Thêm món</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    
                    <!-- THÔNG BÁO LỖI KHÔNG CÓ DỮ LIỆU -->
                    <c:if test="${empty drinks}">
                        <div class="col-12 py-5 text-center">
                            <div class="glass-panel p-5 mx-auto" style="max-width: 600px;">
                                <i class="bi bi-cup-hot text-success fs-1 mb-3"></i>
                                <h4 class="fw-bold mb-3">Chào mừng bạn đến với CoffeePoly!</h4>
                                <p class="text-muted mb-4">
                                    Hiện tại hệ thống thực đơn chưa được nạp dữ liệu đồ uống hoặc đang nâng cấp.
                                    Quản trị viên vui lòng chạy lại toàn bộ script SQL để chèn dữ liệu mẫu, hoặc thêm các đồ uống ở trạng thái "Đang bán" trong trang quản trị.
                                </p>
                                <a href="${pageContext.request.contextPath}/admin/login" class="btn btn-coffee px-4 rounded-pill">
                                    <i class="bi bi-shield-lock-fill me-2"></i> Truy cập Trang Quản Trị
                                </a>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- CỘT PHẢI: Bảng chứa và tính toán giá tiền (Checkout Panel) -->
            <div class="col-12 col-lg-4">
                <div class="glass-panel p-4 sticky-cart-panel shadow-sm">
                    <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom border-light border-opacity-10">
                        <h5 class="fw-bold mb-0 brand-title">
                            <i class="bi bi-cart-check-fill text-success me-2"></i>Giỏ hàng của bạn
                        </h5>
                        <button type="button" class="btn btn-sm btn-outline-danger border-0 p-1" id="clearCartBtn" title="Xóa tất cả món" style="display:none;" onclick="confirmClearCart()">
                            <i class="bi bi-trash3 me-1"></i><small class="fw-semibold">Xóa hết</small>
                        </button>
                    </div>

                    <!-- Danh sách món đặt nước uống -->
                    <div id="cartItemsList" class="mb-3" style="max-height: 250px; overflow-y: auto;">
                        <div class="text-center text-muted py-4" id="emptyCartMessage">
                            <i class="bi bi-basket fs-2 d-block mb-2"></i>
                            Chưa chọn món nước nào.
                        </div>
                    </div>

                    <!-- Tổng cộng chi phí tính toán -->
                    <div class="glass-panel p-3 mb-4" style="background: rgba(45, 26, 18, 0.02); border-color: rgba(45, 26, 18, 0.06);">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="text-muted small">Tạm tính:</span>
                            <span class="fw-bold text-dark" id="drawerSubTotal">0đ</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2" id="discountRow" style="display: none !important;">
                            <span class="text-danger small" id="discountLabel"><i class="bi bi-percent me-1"></i>Giảm giá (0%):</span>
                            <span class="fw-bold text-danger" id="drawerDiscount">-0đ</span>
                        </div>
                        <hr class="my-2 border-secondary border-opacity-10">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted fw-bold">Tổng thanh toán:</span>
                            <span class="fs-4 fw-bold text-success" id="drawerTotalSum">0đ</span>
                        </div>
                    </div>

                    <!-- Form thông tin khách hàng & Đặt hàng -->
                    <form action="${pageContext.request.contextPath}/place-order" method="POST" id="orderCheckoutForm" onsubmit="return validateCheckoutForm()">
                        <h6 class="fw-bold mb-3 brand-title"><i class="bi bi-person-badge-fill text-success me-2"></i>Thông tin đặt hàng</h6>
                        
                        <!-- Tên khách hàng (Có tự động gợi ý & nhận diện SĐT) -->
                        <div class="mb-3 position-relative">
                            <label for="customerName" class="form-label text-muted small fw-bold">
                                Tên khách hàng <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control glass-input w-100" id="customerName" name="customerName" 
                                   placeholder="Nhập tên của bạn (Tự nhận diện SĐT)" required autocomplete="off">
                            <div id="customerSuggestions" class="dropdown-menu shadow-lg w-100 p-0 overflow-hidden mt-1 bg-white" 
                                 style="display:none; position:absolute; z-index:1050; border-radius: 12px; border: 1px solid rgba(0,112,74,0.2);">
                            </div>
                            <div class="invalid-feedback text-danger" id="nameError" style="display:none;">Tên từ 2-50 kí tự tiếng Việt có dấu.</div>
                        </div>

                        <!-- Số điện thoại -->
                        <div class="mb-3">
                            <label for="customerPhone" class="form-label text-muted small fw-bold">
                                Số điện thoại <span class="text-danger">*</span>
                            </label>
                            <div class="input-group">
                                <input type="tel" class="form-control glass-input" id="customerPhone" name="customerPhone" 
                                       placeholder="Ví dụ: 0912345678" required oninput="checkCustomerPoints(this.value)" onchange="checkCustomerPoints(this.value)">
                                <button type="button" class="btn btn-outline-success fw-semibold px-3" onclick="checkCustomerPoints(document.getElementById('customerPhone').value)">
                                    <i class="bi bi-search me-1"></i> Tra điểm
                                </button>
                            </div>
                            <div class="invalid-feedback text-danger" id="phoneError" style="display:none;">Số điện thoại không hợp lệ (10 số).</div>
                            <small class="text-success fw-bold d-block mt-1" id="customerStatusInfo" style="display:none;"></small>
                        </div>

                        <!-- Ô nhập điểm tích lũy để giảm giá (LUÔN HIỂN THỊ RÕ RÀNG) -->
                        <div class="mb-3 p-3 rounded-3 border bg-white shadow-sm" style="border-color: rgba(0, 112, 74, 0.2) !important;">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                                <label for="usePointsInput" class="form-label text-success fw-bold m-0 small">
                                    <i class="bi bi-gift-fill me-1"></i>Sử dụng điểm tích lũy giảm giá
                                </label>
                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1 rounded-pill small" id="userPointsBadge">
                                    0 điểm khả dụng
                                </span>
                            </div>
                            <small class="text-muted d-block mb-2" style="font-size: 0.82rem;">
                                <i class="bi bi-info-circle me-1"></i>Tỷ lệ đổi: <strong>50 điểm = 7% giảm giá</strong> (Cần tối thiểu 50 điểm, mốc tối đa 200 điểm/lần)
                            </small>
                            <div class="input-group input-group-sm">
                                <input type="number" class="form-control glass-input" id="usePointsInput" name="usePoints" 
                                       placeholder="Nhập điểm đổi (50, 100, 150, 200)" min="0" max="200" step="50" value="0" oninput="updateCartUI()" onchange="updateCartUI()">
                                <button type="button" class="btn btn-success fw-bold px-3" onclick="setMaxPoints()">
                                    Đổi tối đa
                                </button>
                            </div>
                            <div class="mt-2" id="discountNoteContainer" style="display:none;">
                                <span class="badge bg-danger bg-opacity-10 text-danger border border-danger-subtle p-2 w-100 text-start font-monospace" id="discountNote" style="font-size: 0.85rem;"></span>
                            </div>
                        </div>

                        <!-- Hình thức đặt món -->
                        <div class="mb-3">
                            <label for="orderType" class="form-label text-muted small fw-bold">Hình thức phục vụ <span class="text-danger">*</span></label>
                            <select class="form-select glass-input w-100 fw-bold" id="orderType" name="orderType" onchange="toggleTableSelection()">
                                <option value="TaiCho" selected>☕ Tại quán (Chọn số bàn)</option>
                                <option value="MangVe">🛍️ Mang về / Mang đi</option>
                            </select>
                        </div>

                        <!-- Khối chọn số bàn hiện tại (Chỉ hiển thị khi chọn Tại quán) -->
                        <div class="mb-3" id="tableSelectionContainer">
                            <label for="tableId" class="form-label text-muted small fw-bold">
                                <i class="bi bi-grid-3x3-gap-fill text-warning me-1"></i>Số bàn hiện tại đang sử dụng <span class="text-danger">*</span>
                            </label>
                            
                            <c:set var="targetIdStr" value="${scannedTable.maBan}" />
                            <c:if test="${empty targetIdStr}"><c:set var="targetIdStr" value="${sessionScope.sessionTableId}" /></c:if>
                            <c:if test="${empty targetIdStr}"><c:set var="targetIdStr" value="${param.tableId}" /></c:if>
                            <c:if test="${empty targetIdStr}"><c:set var="targetIdStr" value="${param.table}" /></c:if>
                            <c:if test="${empty targetIdStr}"><c:set var="targetIdStr" value="${param.qr}" /></c:if>

                            <c:set var="targetTenBan" value="${scannedTable.tenBan}" />
                            <c:if test="${empty targetTenBan}"><c:set var="targetTenBan" value="${sessionScope.sessionTableName}" /></c:if>

                            <c:choose>
                                <c:when test="${not empty targetTenBan && not empty targetIdStr}">
                                    <div class="alert alert-success border-0 bg-success bg-opacity-10 text-success p-2.5 rounded-3 mb-0 small d-flex align-items-center shadow-sm">
                                        <i class="bi bi-qr-code-scan fs-4 me-2 text-success"></i>
                                        <div>
                                            <strong>Đã tự động nhận diện: ${targetTenBan}</strong>
                                            <small class="d-block text-muted" style="font-size: 0.74rem;">Xác định tự động từ mã QR vị trí bàn của quý khách</small>
                                        </div>
                                    </div>
                                    <input type="hidden" id="tableId" name="tableId" value="${targetIdStr}">
                                </c:when>
                                <c:otherwise>
                                    <select class="form-select glass-input w-100 fw-bold" id="tableId" name="tableId" required>
                                        <option value="" disabled selected>-- Chọn số bàn quý khách đang ngồi --</option>
                                        <c:forEach var="t" items="${tables}">
                                            <option value="${t.maBan}">
                                                📍 ${t.tenBan}
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <small class="text-muted d-block mt-1" style="font-size: 0.78rem;">
                                        <i class="bi bi-info-circle me-1"></i>Vui lòng chọn đúng số bàn quý khách đang ngồi để nhân viên phục vụ tận nơi.
                                    </small>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Ghi chú món nước -->
                        <div class="mb-3">
                            <label for="note" class="form-label text-muted small fw-bold">Ghi chú pha chế</label>
                            <textarea class="form-control glass-input w-100" id="note" name="note" rows="2" placeholder="Ví dụ: Ít đá, ít ngọt..."></textarea>
                        </div>

                        <!-- Nơi chứa các input ẩn chứa giỏ hàng gửi lên server -->
                        <div id="hiddenCartInputs"></div>

                        <!-- Nút Đặt món -->
                        <button type="button" id="submitOrderBtn" onclick="submitOrder()" class="btn btn-coffee w-100 py-3 fs-5 mt-2">
                            <i class="bi bi-check2-circle me-2"></i> Gửi Yêu Cầu Đặt Món
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Javascript xử lý hoạt động Menu, Giỏ hàng & Lọc dữ liệu -->
    <script>
        // Trạng thái giỏ hàng & điểm tích lũy
        let cart = [];
        let activeCategory = 'all';
        let currentCustomerPoints = 0;

        // 1. Tải giỏ hàng từ sessionStorage (chỉ lưu trong phiên tab hiện tại, tránh lưu lại giỏ hàng dở dang cho khách sau)
        document.addEventListener("DOMContentLoaded", function() {
            const tableSelect = document.getElementById("tableId");
            let currentTableId = tableSelect ? tableSelect.value : "";

            // Xóa triệt để các cache giỏ hàng & thông tin cũ lưu trong localStorage
            try {
                localStorage.removeItem("coffee_cart");
                localStorage.removeItem("coffee_cart_table_id");
                localStorage.removeItem("coffee_table_id");
                localStorage.removeItem("coffee_cust_name");
                localStorage.removeItem("coffee_cust_phone");
            } catch (e) {}

            const isQrScan = window.location.search.includes('table') || window.location.search.includes('qr');
            const savedSessionTableId = sessionStorage.getItem("coffee_cart_table_id") || "";

            // Nếu truy cập/quét mã QR bàn mới HOẶC vị trí bàn bị thay đổi -> Xóa giỏ hàng dở dang cũ để khách sau luôn có menu trống
            if (isQrScan || (currentTableId && savedSessionTableId && currentTableId !== savedSessionTableId)) {
                cart = [];
                sessionStorage.removeItem("coffee_cart");
                if (currentTableId) sessionStorage.setItem("coffee_cart_table_id", currentTableId);
            } else if (sessionStorage.getItem("coffee_cart")) {
                try {
                    cart = JSON.parse(sessionStorage.getItem("coffee_cart"));
                } catch (e) {
                    cart = [];
                }
            }

            if (currentTableId) {
                sessionStorage.setItem("coffee_cart_table_id", currentTableId);
            }

            // Lắng nghe sự kiện nếu khách chọn đổi số bàn trên giao diện -> Reset giỏ hàng theo bàn mới
            if (tableSelect) {
                tableSelect.addEventListener("change", function() {
                    const newTableId = this.value;
                    const prevCartTableId = sessionStorage.getItem("coffee_cart_table_id") || "";
                    if (newTableId && prevCartTableId && newTableId !== prevCartTableId) {
                        cart = [];
                        sessionStorage.removeItem("coffee_cart");
                        sessionStorage.setItem("coffee_cart_table_id", newTableId);
                        updateCartUI();
                    }
                });
            }
            // Khởi tạo ẩn hiện số bàn theo hình thức phục vụ
            toggleTableSelection();

            // Đảm bảo ô Tên và SĐT khách hàng luôn trống ban đầu
            const nameInput = document.getElementById("customerName");
            const phoneInput = document.getElementById("customerPhone");
            if (nameInput) nameInput.value = "";
            if (phoneInput) phoneInput.value = "";

            updateCartUI();

            // Tự động nhận diện & gợi ý số điện thoại khi nhập Tên khách hàng
            const suggestionsEl = document.getElementById("customerSuggestions");
            let searchTimeout = null;

            if (nameInput && suggestionsEl) {
                nameInput.addEventListener("input", function() {
                    const query = this.value.trim();
                    if (searchTimeout) clearTimeout(searchTimeout);

                    if (query.length < 2) {
                        suggestionsEl.style.display = "none";
                        suggestionsEl.innerHTML = "";
                        return;
                    }

                    searchTimeout = setTimeout(() => {
                        fetch('${pageContext.request.contextPath}/check-points?query=' + encodeURIComponent(query))
                            .then(res => res.json())
                            .then(data => {
                                suggestionsEl.innerHTML = "";
                                if (data && data.exists && data.customers && data.customers.length > 0) {
                                    data.customers.forEach(cust => {
                                        const item = document.createElement("button");
                                        item.type = "button";
                                        item.className = "dropdown-item py-2 px-3 border-bottom text-start d-flex align-items-center justify-content-between";
                                        item.innerHTML = '<div>' +
                                            '<strong class="text-dark d-block"><i class="bi bi-person-circle text-success me-1"></i>' + cust.name + '</strong>' +
                                            '<small class="text-muted"><i class="bi bi-telephone me-1"></i>' + cust.phone + '</small>' +
                                            '</div>' +
                                            '<span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1 rounded-pill small">' +
                                            cust.points + ' điểm' +
                                            '</span>';
                                        item.onclick = function() {
                                            selectSuggestedCustomer(cust.name, cust.phone);
                                        };
                                        suggestionsEl.appendChild(item);
                                    });

                                    // Nếu chỉ tìm thấy 1 người và tên khớp chính xác, tự động điền SĐT luôn
                                    if (data.customers.length === 1 && data.customers[0].name.toLowerCase() === query.toLowerCase()) {
                                        selectSuggestedCustomer(data.customers[0].name, data.customers[0].phone);
                                    } else {
                                        suggestionsEl.style.display = "block";
                                    }
                                } else {
                                    suggestionsEl.style.display = "none";
                                }
                            })
                            .catch(err => {
                                suggestionsEl.style.display = "none";
                            });
                    }, 200);
                });

                // Đóng danh sách gợi ý khi nhấp ra ngoài
                document.addEventListener("click", function(e) {
                    if (!nameInput.contains(e.target) && !suggestionsEl.contains(e.target)) {
                        suggestionsEl.style.display = "none";
                    }
                });
            }
        });

        // Hàm điền tự động Tên, SĐT và Tra điểm tích lũy khi chọn khách hàng
        function selectSuggestedCustomer(name, phone) {
            const nameInput = document.getElementById("customerName");
            const phoneInput = document.getElementById("customerPhone");
            const suggestionsEl = document.getElementById("customerSuggestions");

            if (nameInput) nameInput.value = name;
            if (phoneInput) {
                phoneInput.value = phone;
                checkCustomerPoints(phone);
            }
            if (suggestionsEl) suggestionsEl.style.display = "none";
        }

        // Bật/Tắt ô chọn Số bàn hiện tại tùy theo Hình thức phục vụ (Tại quán hay Mang về)
        function toggleTableSelection() {
            const orderTypeSelect = document.getElementById("orderType");
            const tableContainer = document.getElementById("tableSelectionContainer");
            const tableSelect = document.getElementById("tableId");
            const autoDetectedTableId = "${targetIdStr}";

            if (orderTypeSelect && tableContainer) {
                if (orderTypeSelect.value === "TaiCho") {
                    tableContainer.style.display = "block";
                    if (tableSelect) {
                        if (tableSelect.tagName === "SELECT") tableSelect.required = true;
                        if (!tableSelect.value && autoDetectedTableId) {
                            tableSelect.value = autoDetectedTableId;
                        }
                    }
                } else {
                    tableContainer.style.display = "none";
                    if (tableSelect) {
                        if (tableSelect.tagName === "SELECT") {
                            tableSelect.required = false;
                            tableSelect.value = "";
                        }
                    }
                }
            }
        }

        // Hàm đọc data-attribute từ nút Thêm món để tránh lỗi ký tự đặc biệt / Base64
        function addToCartFromBtn(btn, event) {
            if (event) {
                event.stopPropagation();
            }
            if (!btn) return;
            const button = btn.closest ? (btn.closest("button") || btn) : btn;
            const idAttr = button.getAttribute("data-id");
            if (!idAttr) return;
            const id = parseInt(idAttr);
            const name = button.getAttribute("data-name") || "Món nước";
            const price = parseFloat(button.getAttribute("data-price")) || 0;
            const img = button.getAttribute("data-img") || "https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500";
            if (isNaN(id) || id <= 0) return;
            addToCart(id, name, price, img);
        }
        window.addToCartFromBtn = addToCartFromBtn;

        // 2. Hàm thêm sản phẩm vào giỏ hàng
        function addToCart(id, name, price, img) {
            if (!id || isNaN(id)) return;
            if (!Array.isArray(cart)) cart = [];
            const existingItem = cart.find(item => item.id === id);
            if (existingItem) {
                existingItem.quantity += 1;
            } else {
                cart.push({
                    id: id,
                    name: name || "Món nước",
                    price: parseFloat(price) || 0,
                    img: img || 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500',
                    quantity: 1
                });
            }
            saveCart();
            updateCartUI();
        }
        window.addToCart = addToCart;

        // Tăng giảm số lượng trong Giỏ hàng
        function changeQty(id, delta) {
            const item = cart.find(item => item.id === id);
            if (item) {
                if (item.quantity === 1 && delta === -1) {
                    confirmRemoveCartItem(id);
                    return;
                }
                item.quantity += delta;
                if (item.quantity <= 0) {
                    cart = cart.filter(c => c.id !== id);
                }
                saveCart();
                updateCartUI();
            }
        }

        let itemToRemoveObj = null;

        // 1. Hàm mở Modal xóa 1 món với ô tùy chỉnh số lượng muốn xóa
        function confirmRemoveCartItem(id) {
            const item = cart.find(i => i.id === id);
            if (!item) return;

            itemToRemoveObj = item;
            const modalImg = document.getElementById("removeItemModalImg");
            const modalName = document.getElementById("removeItemModalName");
            const modalTotalQty = document.getElementById("removeItemModalTotalQty");
            const qtyInput = document.getElementById("removeItemModalQtyInput");

            if (modalImg) modalImg.src = item.img || 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500';
            if (modalName) modalName.innerText = item.name;
            if (modalTotalQty) modalTotalQty.innerText = item.quantity;
            if (qtyInput) {
                qtyInput.max = item.quantity;
                qtyInput.value = item.quantity;
            }

            updateRemoveItemModalCalculation();

            const removeModalEl = document.getElementById('confirmRemoveItemModal');
            if (removeModalEl) {
                const removeModal = new bootstrap.Modal(removeModalEl);
                const confirmBtn = document.getElementById("btnConfirmRemoveItem");
                if (confirmBtn) {
                    confirmBtn.onclick = function() {
                        if (itemToRemoveObj) {
                            const qtyInput = document.getElementById("removeItemModalQtyInput");
                            const qtyToRemove = parseInt(qtyInput ? qtyInput.value : itemToRemoveObj.quantity) || 1;
                            
                            if (qtyToRemove >= itemToRemoveObj.quantity) {
                                cart = cart.filter(c => c.id !== itemToRemoveObj.id);
                            } else {
                                itemToRemoveObj.quantity -= qtyToRemove;
                            }
                            saveCart();
                            updateCartUI();
                            itemToRemoveObj = null;
                        }
                        removeModal.hide();
                    };
                }
                removeModal.show();
            }
        }

        // Thay đổi số lượng muốn xóa ở modal 1 món
        function changeModalRemoveQty(delta) {
            const qtyInput = document.getElementById("removeItemModalQtyInput");
            if (!qtyInput || !itemToRemoveObj) return;
            let currentVal = parseInt(qtyInput.value) || 1;
            currentVal += delta;
            if (currentVal < 1) currentVal = 1;
            if (currentVal > itemToRemoveObj.quantity) currentVal = itemToRemoveObj.quantity;
            qtyInput.value = currentVal;
            updateRemoveItemModalCalculation();
        }

        function setModalRemoveAllQty() {
            const qtyInput = document.getElementById("removeItemModalQtyInput");
            if (!qtyInput || !itemToRemoveObj) return;
            qtyInput.value = itemToRemoveObj.quantity;
            updateRemoveItemModalCalculation();
        }

        function updateRemoveItemModalCalculation() {
            const qtyInput = document.getElementById("removeItemModalQtyInput");
            const subtotalEl = document.getElementById("removeItemModalSubtotal");
            if (!qtyInput || !itemToRemoveObj || !subtotalEl) return;
            
            let val = parseInt(qtyInput.value) || 1;
            if (val < 1) val = 1;
            if (val > itemToRemoveObj.quantity) {
                val = itemToRemoveObj.quantity;
                qtyInput.value = val;
            }
            const reduceAmount = itemToRemoveObj.price * val;
            subtotalEl.innerText = formatMoney(reduceAmount);
        }

        // 2. Hàm mở Modal tùy chỉnh số lượng xóa của TẤT CẢ các món trong giỏ hàng
        function confirmClearCart() {
            if (cart.length === 0) return;
            
            const itemsListContainer = document.getElementById("clearCartModalItemsList");
            if (!itemsListContainer) return;

            let html = '';
            cart.forEach((item) => {
                html += '<div class="d-flex align-items-center justify-content-between p-3 mb-2 bg-white rounded-3 border shadow-sm">';
                html += '  <div class="d-flex align-items-center gap-3" style="max-width: 55%;">';
                html += '    <img src="' + item.img + '" alt="' + item.name + '" class="rounded-3" style="width: 48px; height: 48px; object-fit: cover;">';
                html += '    <div>';
                html += '      <h6 class="fw-bold mb-0 text-dark text-truncate" style="font-size: 0.95rem;">' + item.name + '</h6>';
                html += '      <small class="text-muted">Đang chọn: <strong class="text-dark">' + item.quantity + '</strong> món (' + formatMoney(item.price) + '/món)</small>';
                html += '    </div>';
                html += '  </div>';
                html += '  <div class="d-flex align-items-center gap-2">';
                html += '    <label class="small text-muted mb-0 me-1">Số lượng xóa:</label>';
                html += '    <button type="button" class="btn btn-sm btn-outline-secondary rounded-circle p-0" style="width:28px; height:28px; line-height:1;" onclick="changeClearCartItemRemoveQty(' + item.id + ', -1)">';
                html += '      <i class="bi bi-dash"></i>';
                html += '    </button>';
                html += '    <input type="number" class="form-control text-center fw-bold px-1 clear-cart-qty-input" id="clearQtyInput_' + item.id + '" data-id="' + item.id + '" data-price="' + item.price + '" data-max="' + item.quantity + '" value="' + item.quantity + '" min="0" max="' + item.quantity + '" style="width: 60px; height: 32px;" oninput="updateClearCartModalTotal()">';
                html += '    <button type="button" class="btn btn-sm btn-outline-secondary rounded-circle p-0" style="width:28px; height:28px; line-height:1;" onclick="changeClearCartItemRemoveQty(' + item.id + ', 1)">';
                html += '      <i class="bi bi-plus"></i>';
                html += '    </button>';
                html += '  </div>';
                html += '</div>';
            });

            itemsListContainer.innerHTML = html;
            updateClearCartModalTotal();

            const clearModalEl = document.getElementById('confirmClearCartModal');
            if (clearModalEl) {
                const clearModal = new bootstrap.Modal(clearModalEl);
                const confirmBtn = document.getElementById("btnConfirmClearCart");
                if (confirmBtn) {
                    confirmBtn.onclick = function() {
                        const inputs = document.querySelectorAll('.clear-cart-qty-input');
                        inputs.forEach(inp => {
                            const id = parseInt(inp.getAttribute('data-id'));
                            const qtyToRemove = parseInt(inp.value) || 0;
                            const cartItem = cart.find(c => c.id === id);
                            if (cartItem && qtyToRemove > 0) {
                                cartItem.quantity -= qtyToRemove;
                            }
                        });
                        cart = cart.filter(c => c.quantity > 0);
                        saveCart();
                        updateCartUI();
                        clearModal.hide();
                    };
                }
                clearModal.show();
            }
        }

        function changeClearCartItemRemoveQty(id, delta) {
            const inp = document.getElementById('clearQtyInput_' + id);
            if (!inp) return;
            let max = parseInt(inp.getAttribute('data-max')) || 0;
            let val = parseInt(inp.value) || 0;
            val += delta;
            if (val < 0) val = 0;
            if (val > max) val = max;
            inp.value = val;
            updateClearCartModalTotal();
        }

        function setAllClearCartQtyToMax() {
            const inputs = document.querySelectorAll('.clear-cart-qty-input');
            inputs.forEach(inp => {
                const max = inp.getAttribute('data-max');
                inp.value = max;
            });
            updateClearCartModalTotal();
        }

        function updateClearCartModalTotal() {
            const inputs = document.querySelectorAll('.clear-cart-qty-input');
            let totalReduce = 0;
            inputs.forEach(inp => {
                const price = parseFloat(inp.getAttribute('data-price')) || 0;
                const max = parseInt(inp.getAttribute('data-max')) || 0;
                let val = parseInt(inp.value) || 0;
                if (val < 0) val = 0;
                if (val > max) { val = max; inp.value = max; }
                totalReduce += price * val;
            });
            const totalEl = document.getElementById('clearCartModalTotalReducePrice');
            if (totalEl) totalEl.innerText = formatMoney(totalReduce);
        }

        // Lưu giỏ hàng tạm thời vào sessionStorage (chỉ trong phiên làm việc tab hiện tại)
        function saveCart() {
            const tableSelect = document.getElementById("tableId");
            const currentTableId = tableSelect ? tableSelect.value : "";
            if (currentTableId) {
                sessionStorage.setItem("coffee_cart_table_id", currentTableId);
            }
            sessionStorage.setItem("coffee_cart", JSON.stringify(cart));
        }

        // Tra cứu điểm tích lũy của khách hàng theo SĐT qua AJAX
        function checkCustomerPoints(phone) {
            if (!phone) return;
            phone = phone.trim();
            const phonePattern = /^(0[3|5|7|8|9])+([0-9]{8})$/;
            const statusInfo = document.getElementById("customerStatusInfo");
            const badge = document.getElementById("userPointsBadge");

            if (!phonePattern.test(phone)) {
                if (statusInfo) statusInfo.style.display = "none";
                if (badge) badge.innerText = "0 điểm khả dụng";
                currentCustomerPoints = 0;
                updateCartUI();
                return;
            }

            fetch('${pageContext.request.contextPath}/check-points?phone=' + encodeURIComponent(phone))
                .then(res => res.json())
                .then(data => {
                    if (data && data.exists) {
                        currentCustomerPoints = data.points || 0;
                        if (badge) badge.innerText = currentCustomerPoints + " điểm khả dụng";
                        
                        if (statusInfo) {
                            statusInfo.style.display = "block";
                            if (currentCustomerPoints >= 50) {
                                const maxUsable = Math.min(200, Math.floor(currentCustomerPoints / 50) * 50);
                                const maxDisc = ((maxUsable / 50.0) * 7.0).toFixed(0);
                                statusInfo.innerHTML = '<i class="bi bi-person-check-fill me-1"></i>Thành viên: <strong>' + data.name + '</strong> (' + currentCustomerPoints + ' điểm - Giảm tối đa ' + maxDisc + '%)';
                            } else {
                                statusInfo.innerHTML = '<i class="bi bi-person-check-fill me-1"></i>Thành viên: <strong>' + data.name + '</strong> (' + currentCustomerPoints + ' điểm - Cần từ 50 điểm để đổi giảm giá)';
                            }
                        }
                        
                        const nameInput = document.getElementById("customerName");
                        if (nameInput && !nameInput.value.trim()) {
                            nameInput.value = data.name;
                        }
                    } else {
                        currentCustomerPoints = 0;
                        if (badge) badge.innerText = "0 điểm (Khách mới)";
                        if (statusInfo) {
                            statusInfo.style.display = "block";
                            statusInfo.innerHTML = '<i class="bi bi-person-plus-fill me-1"></i>Khách hàng mới (Chưa có điểm tích lũy)';
                        }
                    }
                    updateCartUI();
                })
                .catch(err => {
                    console.error("Lỗi tra cứu điểm:", err);
                });
        }

        function setMaxPoints() {
            const input = document.getElementById("usePointsInput");
            if (!input) return;

            if (currentCustomerPoints < 50) {
                // Hiển thị Modal Thông báo Rất tiếc không đủ điểm
                const pointsCountEl = document.getElementById("modalCurrentPointsCount");
                if (pointsCountEl) pointsCountEl.innerText = currentCustomerPoints;
                input.value = 0;
                updateCartUI();

                const notEnoughModal = new bootstrap.Modal(document.getElementById('notEnoughPointsModal'));
                notEnoughModal.show();
            } else {
                // Tính toán số điểm tối đa quy đổi
                const maxUsable = Math.min(200, Math.floor(currentCustomerPoints / 50) * 50);
                const discountPercent = ((maxUsable / 50.0) * 7.0).toFixed(0);
                const remainingPoints = currentCustomerPoints - maxUsable;

                // Tính tạm số tiền giảm giá dựa theo giỏ hàng hiện tại
                let drawerSubTotalVal = 0;
                cart.forEach(item => { drawerSubTotalVal += item.price * item.quantity; });
                const discountAmountVal = Math.round(drawerSubTotalVal * (discountPercent / 100.0));

                // Điền dữ liệu vào Modal Xác Nhận
                const totalPointsEl = document.getElementById("modalTotalPointsAvailable");
                const pointsToRedeemEl = document.getElementById("modalPointsToRedeem");
                const discountPercentEl = document.getElementById("modalDiscountPercent");
                const discountAmountEl = document.getElementById("modalDiscountAmount");
                const remainingPointsEl = document.getElementById("modalRemainingPoints");

                if (totalPointsEl) totalPointsEl.innerText = currentCustomerPoints;
                if (pointsToRedeemEl) pointsToRedeemEl.innerText = maxUsable;
                if (discountPercentEl) discountPercentEl.innerText = discountPercent;
                if (discountAmountEl) discountAmountEl.innerText = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(discountAmountVal).replace('₫', 'đ');
                if (remainingPointsEl) remainingPointsEl.innerText = remainingPoints;

                // Mở Modal Xác nhận Đổi Điểm
                const confirmModalEl = document.getElementById('confirmRedeemPointsModal');
                const confirmModal = new bootstrap.Modal(confirmModalEl);

                const confirmBtn = document.getElementById("btnConfirmApplyPoints");
                if (confirmBtn) {
                    confirmBtn.onclick = function() {
                        input.value = maxUsable;
                        updateCartUI();
                        confirmModal.hide();
                    };
                }

                confirmModal.show();
            }
        }

        // Cập nhật giao diện giỏ hàng bên phải
        function updateCartUI() {
            const drawerTotalSum = document.getElementById("drawerTotalSum");
            const drawerSubTotal = document.getElementById("drawerSubTotal");
            const drawerDiscount = document.getElementById("drawerDiscount");
            const discountRow = document.getElementById("discountRow");
            const discountLabel = document.getElementById("discountLabel");
            const discountNote = document.getElementById("discountNote");
            const usePointsInput = document.getElementById("usePointsInput");
            const cartItemsList = document.getElementById("cartItemsList");
            const submitOrderBtn = document.getElementById("submitOrderBtn");
            
            let totalQty = 0;
            let totalPrice = 0;

            const clearCartBtn = document.getElementById("clearCartBtn");
            if (cart.length === 0) {
                if (clearCartBtn) clearCartBtn.style.display = "none";
                cartItemsList.innerHTML = 
                    '<div class="text-center text-muted py-4" id="emptyCartMessage">' +
                    '  <i class="bi bi-basket fs-2 d-block mb-2"></i>' +
                    '  Chưa chọn món nước nào.' +
                    '</div>';
                if (drawerSubTotal) drawerSubTotal.innerText = '0đ';
                if (drawerTotalSum) drawerTotalSum.innerText = '0đ';
                if (discountRow) discountRow.style.setProperty("display", "none", "important");
                if (discountNote) discountNote.style.display = "none";
                if (submitOrderBtn) submitOrderBtn.disabled = true;
                return;
            }

            if (clearCartBtn) clearCartBtn.style.display = "inline-block";
            if (submitOrderBtn) submitOrderBtn.disabled = false;

            // Render danh sách món bằng nối chuỗi
            let itemsHtml = '';
            cart.forEach(item => {
                totalQty += item.quantity;
                totalPrice += item.price * item.quantity;

                itemsHtml += '<div class="d-flex align-items-center justify-content-between mb-3 pb-3 border-bottom border-light border-opacity-10">';
                itemsHtml += '  <div class="d-flex align-items-center" style="max-width: 54%;">';
                itemsHtml += '    <img src="' + item.img + '" alt="' + item.name + '" class="rounded" style="width: 40px; height: 40px; object-fit: cover;">';
                itemsHtml += '    <div class="ms-2">';
                itemsHtml += '      <h6 class="fw-bold mb-0 text-truncate text-wrap" style="font-size: 0.9rem; color: var(--card-text);">' + item.name + '</h6>';
                itemsHtml += '      <small class="text-success fw-bold">' + formatMoney(item.price) + '</small>';
                itemsHtml += '    </div>';
                itemsHtml += '  </div>';
                itemsHtml += '  <div class="d-flex align-items-center gap-1">';
                itemsHtml += '    <button type="button" class="btn btn-sm btn-outline-secondary border-opacity-25 rounded-circle p-0" style="width:24px; height:24px; line-height:1;" onclick="changeQty(' + item.id + ', -1)">';
                itemsHtml += '      <i class="bi bi-dash"></i>';
                itemsHtml += '    </button>';
                itemsHtml += '    <span class="mx-1 fw-bold" style="font-size: 0.9rem; color: var(--card-text);">' + item.quantity + '</span>';
                itemsHtml += '    <button type="button" class="btn btn-sm btn-outline-secondary border-opacity-25 rounded-circle p-0" style="width:24px; height:24px; line-height:1;" onclick="changeQty(' + item.id + ', 1)">';
                itemsHtml += '      <i class="bi bi-plus"></i>';
                itemsHtml += '    </button>';
                itemsHtml += '    <button type="button" class="btn btn-sm btn-outline-danger border-0 p-1 ms-1" title="Xóa món này" onclick="confirmRemoveCartItem(' + item.id + ')">';
                itemsHtml += '      <i class="bi bi-trash3-fill text-danger fs-6"></i>';
                itemsHtml += '    </button>';
                itemsHtml += '  </div>';
                itemsHtml += '</div>';
            });

            cartItemsList.innerHTML = itemsHtml;

            // Tính toán giảm giá theo mốc điểm tích lũy (Cần tối thiểu 50 điểm, 50 điểm = 7% giảm giá, tối đa 200 điểm, mốc bội số 50)
            let rawInputPts = 0;
            let effectivePts = 0;
            if (usePointsInput) {
                rawInputPts = parseInt(usePointsInput.value) || 0;
                if (rawInputPts < 0) rawInputPts = 0;

                if (currentCustomerPoints < 50 && rawInputPts > 0) {
                    alert("Quý khách cần tích lũy tối thiểu từ 50 điểm trở lên mới có thể đổi điểm giảm giá!");
                    rawInputPts = 0;
                    usePointsInput.value = 0;
                } else if (rawInputPts > 200) {
                    rawInputPts = 200;
                    usePointsInput.value = 200;
                } else if (rawInputPts > currentCustomerPoints) {
                    rawInputPts = currentCustomerPoints;
                    usePointsInput.value = rawInputPts;
                }

                if (currentCustomerPoints >= 50 && rawInputPts >= 50) {
                    effectivePts = Math.floor(rawInputPts / 50) * 50;
                    if (effectivePts > 200) effectivePts = 200;
                } else {
                    effectivePts = 0;
                }
            }

            const discountPercent = (effectivePts / 50.0) * 7.0;
            const discountAmount = Math.round(totalPrice * (discountPercent / 100.0));
            const finalTotal = Math.max(0, totalPrice - discountAmount);

            if (drawerSubTotal) drawerSubTotal.innerText = formatMoney(totalPrice);

            if (discountAmount > 0) {
                if (discountRow) discountRow.style.setProperty("display", "flex", "important");
                if (discountLabel) discountLabel.innerHTML = '<i class="bi bi-percent me-1"></i>Giảm giá (' + discountPercent.toFixed(1) + '%):';
                if (drawerDiscount) drawerDiscount.innerText = '-' + formatMoney(discountAmount);
                const discountNoteContainer = document.getElementById("discountNoteContainer");
                if (discountNoteContainer) discountNoteContainer.style.display = "block";
                if (discountNote) {
                    discountNote.innerText = '🎉 Giảm ' + discountPercent.toFixed(1) + '% (-' + formatMoney(discountAmount) + ') từ ' + effectivePts + ' điểm!';
                }
            } else {
                if (discountRow) discountRow.style.setProperty("display", "none", "important");
                const discountNoteContainer = document.getElementById("discountNoteContainer");
                if (discountNoteContainer) discountNoteContainer.style.display = "none";
            }

            if (drawerTotalSum) drawerTotalSum.innerText = formatMoney(finalTotal);
        }

        // Format tiền tệ dạng VNĐ
        function formatMoney(num) {
            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num).replace('₫', 'đ');
        }



        // 3. XỬ LÝ LỌC & TÌM KIẾM ĐỒ UỐNG (Real-time Filtering)
        function selectCategory(catId, element) {
            activeCategory = catId;
            
            document.querySelectorAll('.category-pill').forEach(pill => {
                pill.classList.remove('active');
            });
            element.classList.add('active');

            filterDrinks();
        }

        // Khắc phục bộ lọc bằng cách lấy đúng thuộc tính
        function filterDrinks() {
            const searchVal = document.getElementById("searchInput").value.toLowerCase().trim();
            const sortVal = document.getElementById("sortSelect").value;
            const items = document.querySelectorAll(".drink-card-item");
            
            let visibleCount = 0;
            let drinkArr = [];

            items.forEach(item => {
                const name = item.getAttribute("data-name").toLowerCase();
                const category = item.getAttribute("data-category");

                const matchesCategory = (activeCategory === 'all' || category === activeCategory);
                const matchesSearch = (searchVal === '' || name.includes(searchVal));

                if (matchesCategory && matchesSearch) {
                    item.style.display = "block";
                    drinkArr.push(item);
                    visibleCount++;
                } else {
                    item.style.display = "none";
                }
            });

            // Sắp xếp các món đang hiển thị
            const grid = document.getElementById("drinksGrid");
            if (sortVal === 'asc') {
                drinkArr.sort((a, b) => parseFloat(a.getAttribute("data-price")) - parseFloat(b.getAttribute("data-price")));
                drinkArr.forEach(item => grid.appendChild(item));
            } else if (sortVal === 'desc') {
                drinkArr.sort((a, b) => parseFloat(b.getAttribute("data-price")) - parseFloat(a.getAttribute("data-price")));
                drinkArr.forEach(item => grid.appendChild(item));
            }

            const txt = document.getElementById("drinksCountText");
            if (txt) {
                txt.innerText = "Đang hiển thị: " + visibleCount + " món";
            }
        }

        // 4. BẢO MẬT THÔNG TIN & KIỂM TRA DỮ LIỆU ĐẦU VÀO (Validation)
        function validateCheckoutForm() {
            const name = document.getElementById("customerName").value.trim();
            const phone = document.getElementById("customerPhone").value.trim();
            
            let isValid = true;

            document.getElementById("nameError").style.display = "none";
            document.getElementById("phoneError").style.display = "none";

            // Kiểm tra tên hợp lệ (không chứa ký tự đặc biệt độc hại, dài 2-50 ký tự)
            const namePattern = /^[\p{L}\s']{2,50}$/u;
            if (!namePattern.test(name)) {
                document.getElementById("nameError").style.display = "block";
                isValid = false;
            }

            // Kiểm tra số điện thoại (đủ 10 chữ số)
            const phonePattern = /^(0[3|5|7|8|9])+([0-9]{8})$/;
            if (!phonePattern.test(phone)) {
                document.getElementById("phoneError").style.display = "block";
                isValid = false;
            }

            // Kiểm tra số bàn nếu chọn phục vụ Tại quán
            const orderTypeElem = document.getElementById("orderType");
            const tableElem = document.getElementById("tableId");
            if (orderTypeElem && orderTypeElem.value === "TaiCho") {
                if (!tableElem || !tableElem.value || tableElem.value.trim() === "" || tableElem.value === "null") {
                    alert("Vui lòng chọn số bàn quý khách đang ngồi!");
                    if (tableElem) tableElem.focus();
                    return false;
                }
            }

            // Phòng chống XSS: loại bỏ các ký tự tag HTML
            document.getElementById("customerName").value = name.replace(/<[^>]*>/g, "");
            
            return isValid;
        }

        // Gửi biểu mẫu đặt món lên Server
        function submitOrder() {
            if (cart.length === 0) {
                alert("Giỏ hàng của bạn đang trống!");
                return;
            }

            if (!validateCheckoutForm()) {
                alert("Vui lòng nhập đầy đủ và chính xác thông tin đặt hàng!");
                return;
            }

            const form = document.getElementById("orderCheckoutForm");
            const hiddenContainer = document.getElementById("hiddenCartInputs");
            hiddenContainer.innerHTML = ''; // Xóa sạch dữ liệu cũ

            // Chèn các input ẩn
            cart.forEach(item => {
                const idInput = document.createElement("input");
                idInput.type = "hidden";
                idInput.name = "drinkIds";
                idInput.value = item.id;

                const qtyInput = document.createElement("input");
                qtyInput.type = "hidden";
                qtyInput.name = "quantities";
                qtyInput.value = item.quantity;

                hiddenContainer.appendChild(idInput);
                hiddenContainer.appendChild(qtyInput);
            });

            // Vô hiệu hóa nút để tránh click trùng lặp (Double click prevention)
            const submitBtn = document.getElementById("submitOrderBtn");
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Đang gửi đặt món...';

            // Xóa sạch giỏ hàng trong cả sessionStorage và localStorage sau khi submit thành công
            sessionStorage.removeItem("coffee_cart");
            sessionStorage.removeItem("coffee_cart_table_id");
            localStorage.removeItem("coffee_cart");
            localStorage.removeItem("coffee_cart_table_id");

            form.submit();
        }
    </script>

    <!-- Modal Thông Báo Rất Tiếc (Không đủ điểm đổi) -->
    <div class="modal fade" id="notEnoughPointsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
                <div class="modal-header border-0 bg-warning bg-opacity-10 py-3">
                    <h5 class="modal-title fw-bold text-dark d-flex align-items-center">
                        <i class="bi bi-emoji-frown-fill text-warning fs-3 me-2"></i>
                        Rất tiếc! Chưa đủ điều kiện đổi điểm
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <div class="badge bg-warning-subtle text-warning border border-warning rounded-pill px-3 py-2 fs-6 mb-3">
                        <i class="bi bi-star-fill me-1"></i> Số điểm hiện tại: <span id="modalCurrentPointsCount">0</span> điểm
                    </div>
                    <p class="text-muted mb-3 fs-6">
                        Quý khách chưa đủ điều kiện sử dụng tính năng đổi điểm giảm giá cho đơn hàng này.
                    </p>
                    <div class="alert alert-light border p-3 rounded-3 text-start mb-0">
                        <small class="d-block text-dark fw-bold mb-1"><i class="bi bi-info-circle-fill text-warning me-1"></i> Quy định tích điểm:</small>
                        <ul class="mb-0 text-muted small ps-3">
                            <li>Cần tích lũy <strong>tối thiểu 50 điểm</strong> để bắt đầu đổi giảm giá.</li>
                            <li>Tỷ lệ đổi: <strong>50 điểm = Giảm 7%</strong> tổng hóa đơn.</li>
                            <li>Mỗi <strong>10.000đ</strong> thanh toán đơn hàng bạn sẽ nhận ngay <strong>1 điểm</strong>.</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light p-3 justify-content-center">
                    <button type="button" class="btn btn-warning fw-bold px-4 py-2 rounded-pill text-dark shadow-sm" data-bs-dismiss="modal">
                        <i class="bi bi-check-lg me-1"></i> Đã hiểu
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Xác Nhận Đổi Điểm Tối Đa -->
    <div class="modal fade" id="confirmRedeemPointsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
                <div class="modal-header border-0 bg-success bg-opacity-10 py-3">
                    <h5 class="modal-title fw-bold text-success d-flex align-items-center">
                        <i class="bi bi-gift-fill text-success fs-3 me-2"></i>
                        Xác nhận đổi điểm giảm giá
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="text-secondary mb-3">
                        Bạn có muốn sử dụng số điểm tích lũy tối đa để nhận ưu đãi giảm giá cho đơn hàng này?
                    </p>
                    
                    <div class="glass-panel p-3 rounded-4 mb-3" style="background: rgba(0, 112, 74, 0.05); border: 1px solid rgba(0, 112, 74, 0.15);">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted small">Điểm tích lũy hiện có:</span>
                            <strong class="text-dark"><span id="modalTotalPointsAvailable">0</span> điểm</strong>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted small">Điểm sử dụng tối đa:</span>
                            <strong class="text-success fs-5"><span id="modalPointsToRedeem">0</span> điểm</strong>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted small">Ưu đãi giảm giá nhận được:</span>
                            <strong class="text-danger fs-5">-<span id="modalDiscountPercent">0</span>% (<span id="modalDiscountAmount">0đ</span>)</strong>
                        </div>
                        <hr class="my-2 border-secondary border-opacity-10">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted small">Điểm còn lại sau khi đổi:</span>
                            <span class="fw-bold text-secondary"><span id="modalRemainingPoints">0</span> điểm</span>
                        </div>
                    </div>

                    <small class="text-muted italic d-block text-center">
                        <i class="bi bi-shield-check text-success me-1"></i>Số điểm sử dụng sẽ được tự động trừ sau khi đặt đơn thành công.
                    </small>
                </div>
                <div class="modal-footer border-0 bg-light p-3">
                    <button type="button" class="btn btn-outline-secondary fw-semibold px-4 py-2 rounded-pill" data-bs-dismiss="modal">
                        Hủy bỏ
                    </button>
                    <button type="button" class="btn btn-success fw-bold px-4 py-2 rounded-pill shadow-sm" id="btnConfirmApplyPoints">
                        <i class="bi bi-gift-fill me-1"></i> Đồng ý đổi ngay
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Xác Nhận Xóa 1 Món Khỏi Giỏ Hàng -->
    <div class="modal fade" id="confirmRemoveItemModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
                <div class="modal-header border-0 bg-danger bg-opacity-10 py-3">
                    <h5 class="modal-title fw-bold text-danger d-flex align-items-center">
                        <i class="bi bi-trash3-fill text-danger fs-3 me-2"></i>
                        Xác nhận xóa món
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <img id="removeItemModalImg" src="" alt="Món nước" class="rounded-3 mb-3 shadow-sm" style="width: 70px; height: 70px; object-fit: cover;">
                    <h6 class="fw-bold text-dark mb-1 fs-5" id="removeItemModalName">Tên món</h6>
                    <p class="text-muted small mb-3">Vui lòng chọn số lượng bạn muốn giảm hoặc xóa khỏi giỏ hàng:</p>
                    
                    <div class="glass-panel p-3 rounded-3 mb-3 bg-light border">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="text-muted small fw-bold">Số lượng hiện có trong giỏ:</span>
                            <span class="badge bg-secondary rounded-pill px-3 py-1 fs-6" id="removeItemModalTotalQty">0</span>
                        </div>
                        
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <label for="removeItemModalQtyInput" class="text-dark small fw-bold me-2">Số lượng muốn xóa:</label>
                            <div class="d-flex align-items-center gap-1">
                                <button type="button" class="btn btn-sm btn-outline-danger rounded-circle p-0" style="width:30px; height:30px; line-height:1;" onclick="changeModalRemoveQty(-1)">
                                    <i class="bi bi-dash fs-6"></i>
                                </button>
                                <input type="number" id="removeItemModalQtyInput" class="form-control glass-input text-center fw-bold px-1" style="width: 65px; height: 34px;" value="1" min="1" oninput="updateRemoveItemModalCalculation()">
                                <button type="button" class="btn btn-sm btn-outline-danger rounded-circle p-0" style="width:30px; height:30px; line-height:1;" onclick="changeModalRemoveQty(1)">
                                    <i class="bi bi-plus fs-6"></i>
                                </button>
                            </div>
                        </div>

                        <div class="text-end mb-2">
                            <button type="button" class="btn btn-link btn-sm text-danger p-0 text-decoration-none" onclick="setModalRemoveAllQty()">
                                <i class="bi bi-check2-all me-1"></i>Chọn xóa tất cả số lượng món này
                            </button>
                        </div>

                        <hr class="my-2 border-secondary border-opacity-10">

                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-muted small">Số tiền tương ứng giảm:</span>
                            <span class="fw-bold text-danger fs-5" id="removeItemModalSubtotal">0đ</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light p-3 justify-content-center">
                    <button type="button" class="btn btn-outline-secondary fw-semibold px-4 py-2 rounded-pill" data-bs-dismiss="modal">
                        Hủy bỏ
                    </button>
                    <button type="button" class="btn btn-danger fw-bold px-4 py-2 rounded-pill shadow-sm" id="btnConfirmRemoveItem">
                        <i class="bi bi-trash3-fill me-1"></i> Đồng ý xóa
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Tùy Chỉnh Số Lượng Xóa Cho Tất Cả Món -->
    <div class="modal fade" id="confirmClearCartModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
                <div class="modal-header border-0 bg-danger bg-opacity-10 py-3">
                    <h5 class="modal-title fw-bold text-danger d-flex align-items-center">
                        <i class="bi bi-trash3-fill text-danger fs-3 me-2"></i>
                        Số lượng xóa của tất cả món đã chọn
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="text-muted small mb-3">Tùy chỉnh số lượng cần giảm/xóa cho từng món nước bạn đã thêm vào giỏ hàng:</p>
                    
                    <!-- Danh sách các món trong giỏ hàng -->
                    <div id="clearCartModalItemsList" class="mb-3 overflow-y-auto pe-1" style="max-height: 320px;">
                    </div>

                    <div class="d-flex justify-content-between align-items-center bg-light p-3 rounded-3 border">
                        <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-3" onclick="setAllClearCartQtyToMax()">
                            <i class="bi bi-trash3 me-1"></i>Chọn xóa toàn bộ giỏ hàng
                        </button>
                        <div>
                            <span class="text-muted small me-2">Tổng tiền giảm:</span>
                            <span class="fw-bold text-danger fs-5" id="clearCartModalTotalReducePrice">0đ</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light p-3 justify-content-center">
                    <button type="button" class="btn btn-outline-secondary fw-semibold px-4 py-2 rounded-pill" data-bs-dismiss="modal">
                        Hủy bỏ
                    </button>
                    <button type="button" class="btn btn-danger fw-bold px-4 py-2 rounded-pill shadow-sm" id="btnConfirmClearCart">
                        <i class="bi bi-check2-circle me-1"></i> Xác nhận xóa
                    </button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
