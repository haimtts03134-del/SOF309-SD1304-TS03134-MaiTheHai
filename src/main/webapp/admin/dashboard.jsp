<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung (Chứa Sidebar & Top Navbar) -->
<jsp:include page="common/header.jsp" />

<div class="container-fluid px-0">
    <div class="row mb-4 align-items-center">
        <div class="col-12 col-md-7">
            <h2 class="fw-bold text-dark mb-1">Tổng Quan Hoạt Động</h2>
            <p class="text-muted mb-0">Cập nhật thống kê hoạt động kinh doanh của quán nước (Tháng ${displayMonth}).</p>
        </div>
        <div class="col-12 col-md-5 text-md-end mt-2 mt-md-0">
            <form action="${pageContext.request.contextPath}/admin/dashboard" method="get" class="d-inline-flex align-items-center gap-2">
                <label for="monthSelect" class="form-label fw-semibold text-secondary mb-0 text-nowrap">
                    <i class="bi bi-calendar3 me-1"></i>Chọn tháng:
                </label>
                <input type="month" class="form-control form-control-sm rounded-3 border-secondary-subtle fw-bold shadow-sm" 
                       id="monthSelect" name="month" value="${selectedMonth}" onchange="this.form.submit()">
            </form>
        </div>
    </div>

    <!-- Hàng chứa thẻ Chỉ số KPI -->
    <div class="row g-4 mb-5">
        <!-- Doanh thu thẻ -->
        <div class="col-12 col-md-4">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="bi bi-wallet2"></i>
                </div>
                <div class="stat-title">Doanh Thu (Tháng ${displayMonth})</div>
                <div class="stat-number">
                    <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                </div>
            </div>
        </div>

        <!-- Đơn hàng thẻ -->
        <div class="col-12 col-md-4">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="bi bi-receipt"></i>
                </div>
                <div class="stat-title">Đơn Hàng Đã Giao</div>
                <div class="stat-number">${ordersCount} đơn</div>
            </div>
        </div>

        <!-- Món bán chạy thẻ -->
        <div class="col-12 col-md-4">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="bi bi-cup-hot"></i>
                </div>
                <div class="stat-title">Món Trong Thực Đơn</div>
                <div class="stat-number">${drinksCount} món</div>
            </div>
        </div>
    </div>

    <!-- Hàng chứa: Nước Bán Chạy Nhất & Nhân Viên Xuất Sắc -->
    <div class="row g-4 mb-4">
        <!-- 1. Bảng Các loại nước bán chạy nhất -->
        <div class="col-12 col-md-6">
            <div class="custom-card h-100">
                <div class="card-title-container">
                    <h5 class="custom-card-title"><i class="bi bi-star-fill me-2 text-warning"></i>Nước Bán Chạy Nhất</h5>
                </div>
                <div class="table-responsive">
                    <table class="table custom-table">
                        <thead>
                            <tr>
                                <th>Tên Món</th>
                                <th class="text-end">Đã Bán</th>
                                <th class="text-end">Doanh Thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty bestSellers}">
                                    <c:forEach var="drink" items="${bestSellers}">
                                        <tr>
                                            <td>
                                                <div class="fw-semibold">${drink.name}</div>
                                                <small class="text-muted">${drink.category}</small>
                                            </td>
                                            <td class="text-end"><strong>${drink.soldCount} ly</strong></td>
                                            <td class="text-end text-success"><fmt:formatNumber value="${drink.totalSales}" type="currency" currencySymbol="đ" maxFractionDigits="0" /></td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted py-4">
                                            <i class="bi bi-info-circle me-1"></i>Chưa có dữ liệu bán hàng trong tháng ${displayMonth}
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 2. Bảng Nhân viên xuất sắc của tháng -->
        <div class="col-12 col-md-6">
            <div class="custom-card h-100">
                <div class="card-title-container">
                    <h5 class="custom-card-title"><i class="bi bi-award-fill me-2 text-warning"></i>Nhân Viên Xuất Sắc</h5>
                </div>
                <div class="table-responsive">
                    <table class="table custom-table">
                        <thead>
                            <tr>
                                <th>Nhân Viên</th>
                                <th class="text-end">Số Đơn</th>
                                <th class="text-end">Hiệu Suất</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty topEmployees}">
                                    <c:forEach var="emp" items="${topEmployees}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="${emp.avatar}" class="avatar-table" alt="${emp.name}">
                                                    <div>
                                                        <div class="fw-semibold">${emp.name}</div>
                                                        <small class="text-muted">${emp.role}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="text-end"><strong>${emp.orders}</strong></td>
                                            <td class="text-end text-primary"><fmt:formatNumber value="${emp.sales}" type="currency" currencySymbol="đ" maxFractionDigits="0" /></td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted py-4">
                                            <i class="bi bi-info-circle me-1"></i>Chưa có dữ liệu nhân viên trong tháng ${displayMonth}
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Hàng chứa: Giao Dịch Gần Đây (Chiếm 100% bề rộng) -->
    <div class="row g-4">
        <!-- 3. Bảng Thống kê Doanh thu & Hóa đơn gần đây -->
        <div class="col-12">
            <div class="custom-card">
                <div class="card-title-container d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                    <div>
                        <h5 class="custom-card-title d-inline-block mb-0 me-2"><i class="bi bi-currency-dollar me-2 text-warning"></i>Giao Dịch Gần Đây</h5>
                        <span class="badge bg-light text-dark border">Tháng ${displayMonth}</span>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <!-- Nút Mở Pop-up xem tất cả đơn hàng -->
                        <button type="button" class="btn btn-sm btn-coffee fw-semibold shadow-sm" data-bs-toggle="modal" data-bs-target="#allMonthOrdersModal">
                            <i class="bi bi-window-stack me-1"></i>Xem tất cả đơn (${monthOrders != null ? monthOrders.size() : 0})
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/invoices" class="btn btn-sm btn-outline-dark fw-semibold">
                            <i class="bi bi-receipt me-1"></i>Quản lý hóa đơn
                        </a>
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table custom-table align-middle">
                        <thead>
                            <tr>
                                <th>Mã Hóa Đơn</th>
                                <th>Thời Gian</th>
                                <th>Số Tiền</th>
                                <th>Phương Thức</th>
                                <th>Trạng Thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty recentTransactions}">
                                    <c:forEach var="tx" items="${recentTransactions}">
                                        <tr>
                                            <td><strong>${tx.id}</strong></td>
                                            <td>${tx.time}</td>
                                            <td class="fw-bold text-dark"><fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0" /></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${tx.method == 'Ví MoMo'}"><span class="badge bg-danger-subtle text-danger" style="font-size: 0.8rem;">MoMo</span></c:when>
                                                    <c:when test="${tx.method == 'Ví VNPAY'}"><span class="badge bg-primary-subtle text-primary" style="font-size: 0.8rem;">VNPAY</span></c:when>
                                                    <c:when test="${tx.method == 'ChuyenKhoan'}"><span class="badge bg-info-subtle text-info" style="font-size: 0.8rem;">Chuyển khoản</span></c:when>
                                                    <c:otherwise><span class="badge bg-secondary-subtle text-dark" style="font-size: 0.8rem;">Tiền mặt</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${tx.status == 'Đã hủy'}">
                                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; font-size: 0.82rem;">
                                                            <i class="bi bi-x-circle-fill me-1"></i>Đã hủy
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${tx.status == 'Đã thanh toán'}">
                                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; font-size: 0.82rem;">
                                                            <i class="bi bi-check-circle-fill me-1"></i>Đã thanh toán
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${tx.status == 'Đang chế biến'}">
                                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #cff4fc; color: #055160; border: 1px solid #b6effb; font-size: 0.82rem;">
                                                            <i class="bi bi-cup-hot-fill me-1"></i>Đang chế biến
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${tx.status == 'Đã giao món'}">
                                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #e0cffc; color: #3d0a91; border: 1px solid #c5b3f8; font-size: 0.82rem;">
                                                            <i class="bi bi-send-check-fill me-1"></i>Đã giao món
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #fff3cd; color: #664d03; border: 1px solid #ffecb5; font-size: 0.82rem;">
                                                            <i class="bi bi-clock-history me-1"></i>${tx.status}
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">
                                            <i class="bi bi-inbox me-1"></i>Chưa phát sinh giao dịch nào trong tháng ${displayMonth}
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL POP-UP: HIỂN THỊ TOÀN BỘ ĐƠN HÀNG TRONG HỆ THỐNG (CÓ THỂ CUỘN, CÓ TÊN NHÂN VIÊN) -->
<div class="modal fade" id="allMonthOrdersModal" tabindex="-1" aria-labelledby="allMonthOrdersModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header text-white py-3" style="background-color: var(--bg-dark); border-bottom: 2px solid var(--secondary-gold);">
                <h5 class="modal-title fw-bold" id="allMonthOrdersModalLabel" style="color: var(--secondary-gold);">
                    <i class="bi bi-receipt-cutoff me-2"></i>Danh Sách Tất Cả Đơn Hàng (${monthOrders != null ? monthOrders.size() : 0} đơn)
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-0">
                <!-- Thanh tìm kiếm nhanh bên trong Modal -->
                <div class="p-3 bg-light border-bottom d-flex flex-wrap justify-content-between align-items-center gap-2">
                    <span class="text-secondary small fw-semibold">
                        <i class="bi bi-info-circle me-1 text-primary"></i>Danh sách hiển thị kèm Nhân viên phụ trách. Bạn có thể cuộn xuống để xem toàn bộ.
                    </span>
                    <div class="input-group input-group-sm" style="max-width: 280px;">
                        <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" id="modalOrderSearchInput" class="form-control border-start-0 ps-0" placeholder="Lọc Mã HD, Nhân viên..." onkeyup="filterModalOrders()">
                    </div>
                </div>

                <!-- Bảng danh sách hóa đơn có thể cuộn (Scrollable) -->
                <div class="table-responsive" style="max-height: 480px; overflow-y: auto;">
                    <table class="table custom-table table-hover align-middle mb-0" id="modalOrdersTable">
                        <thead class="table-dark sticky-top" style="z-index: 2;">
                            <tr>
                                <th>Mã Hóa Đơn</th>
                                <th>Thời Gian</th>
                                <th>Hình Thức</th>
                                <th>Nhân Viên Phụ Trách</th>
                                <th>Tổng Tiền</th>
                                <th>Trạng Thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="order" items="${monthOrders}">
                                <tr>
                                    <td><strong class="text-primary">${order.id}</strong></td>
                                    <td class="small text-secondary fw-medium">${order.time}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.isTaiCho || order['isTaiCho'] || order.method != 'Mang về'}">
                                                <span class="badge bg-info-subtle text-info border border-info-subtle px-2.5 py-1.5" style="font-size: 0.82rem;"><i class="bi bi-shop me-1"></i>${order.method == 'Tại bàn' ? 'Tại quán' : order.method}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary-subtle text-dark border border-secondary-subtle px-2.5 py-1.5" style="font-size: 0.82rem;"><i class="bi bi-bag-check me-1"></i>Mang về</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <div class="rounded-circle bg-warning bg-opacity-25 text-dark fw-bold d-flex align-items-center justify-content-center border border-warning" style="width: 32px; height: 32px; font-size: 0.85rem;">
                                                <i class="bi bi-person-badge-fill text-warning"></i>
                                            </div>
                                            <span class="fw-bold text-dark" style="font-size: 0.9rem;">${order.staffName}</span>
                                        </div>
                                    </td>
                                    <td class="fw-bold text-dark fs-6">
                                        <fmt:formatNumber value="${order.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.status == 'Đã hủy'}">
                                                <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; font-size: 0.82rem;">
                                                    <i class="bi bi-x-circle-fill me-1"></i>Đã hủy
                                                </span>
                                            </c:when>
                                            <c:when test="${order.status == 'Đã thanh toán'}">
                                                <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; font-size: 0.82rem;">
                                                    <i class="bi bi-check-circle-fill me-1"></i>Đã thanh toán
                                                </span>
                                            </c:when>
                                            <c:when test="${order.status == 'Đang chế biến'}">
                                                <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #cff4fc; color: #055160; border: 1px solid #b6effb; font-size: 0.82rem;">
                                                    <i class="bi bi-cup-hot-fill me-1"></i>Đang chế biến
                                                </span>
                                            </c:when>
                                            <c:when test="${order.status == 'Đã giao món'}">
                                                <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #e0cffc; color: #3d0a91; border: 1px solid #c5b3f8; font-size: 0.82rem;">
                                                    <i class="bi bi-send-check-fill me-1"></i>Đã giao món
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill px-3 py-1.5 fw-semibold" style="background-color: #fff3cd; color: #664d03; border: 1px solid #ffecb5; font-size: 0.82rem;">
                                                    <i class="bi bi-clock-history me-1"></i>${order.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty monthOrders}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-2 text-secondary"></i>Chưa có đơn hàng nào trong tháng này
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer bg-light py-2">
                <button type="button" class="btn btn-secondary px-4 fw-semibold" data-bs-dismiss="modal">
                    <i class="bi bi-x-lg me-1"></i>Đóng
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    function filterModalOrders() {
        const input = document.getElementById('modalOrderSearchInput');
        if (!input) return;
        const filter = input.value.toLowerCase();
        const table = document.getElementById('modalOrdersTable');
        if (!table) return;
        const tr = table.getElementsByTagName('tr');

        for (let i = 1; i < tr.length; i++) {
            const row = tr[i];
            if (row.getElementsByTagName('td').length > 0) {
                const textContent = row.textContent || row.innerText;
                if (textContent.toLowerCase().indexOf(filter) > -1) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        }
    }
</script>

<!-- Nhúng Footer dùng chung (Đóng các thẻ div và thêm scripts) -->
<jsp:include page="common/footer.jsp" />

