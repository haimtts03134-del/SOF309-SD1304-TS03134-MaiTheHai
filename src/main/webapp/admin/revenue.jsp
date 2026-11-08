<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung -->
<jsp:include page="common/header.jsp" />

<div class="container-fluid px-0">
    <!-- Tiêu đề trang -->
    <div class="row mb-4">
        <div class="col-12 col-md-6">
            <h2 class="fw-bold text-dark"><i class="bi bi-bar-chart-line-fill text-warning me-2"></i>Thống Kê Doanh Thu</h2>
            <p class="text-muted">Theo dõi chỉ số kinh doanh, phân tích xu hướng doanh thu và tỷ trọng sản phẩm bán ra.</p>
        </div>
        <!-- Bộ lọc ngày -->
        <div class="col-12 col-md-6 d-flex align-items-center justify-content-md-end">
            <form action="${pageContext.request.contextPath}/admin/revenue" method="get" class="row g-2 align-items-center">
                <div class="col-auto">
                    <input type="date" class="form-control" name="startDate" value="${startDateStr}" required>
                </div>
                <div class="col-auto text-muted">đến</div>
                <div class="col-auto">
                    <input type="date" class="form-control" name="endDate" value="${endDateStr}" required>
                </div>
                <div class="col-auto">
                    <button type="submit" class="btn btn-coffee px-3">
                        <i class="bi bi-filter me-1"></i>Lọc
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Khối thẻ KPI nổi bật -->
    <div class="row g-4 mb-4">
        <!-- Doanh thu tổng -->
        <div class="col-12 col-sm-4">
            <div class="stat-card">
                <div class="stat-icon bg-success-subtle text-success">
                    <i class="bi bi-cash-coin"></i>
                </div>
                <div class="stat-title">Tổng Doanh Thu</div>
                <div class="stat-number text-success">
                    <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                </div>
            </div>
        </div>

        <!-- Tổng đơn hàng -->
        <div class="col-12 col-sm-4">
            <div class="stat-card">
                <div class="stat-icon bg-primary-subtle text-primary">
                    <i class="bi bi-receipt-cutoff"></i>
                </div>
                <div class="stat-title">Số Đơn Hoàn Thành</div>
                <div class="stat-number text-primary">${totalOrders} đơn</div>
            </div>
        </div>

        <!-- Doanh thu trung bình / đơn -->
        <div class="col-12 col-sm-4">
            <div class="stat-card">
                <div class="stat-icon bg-warning-subtle text-warning">
                    <i class="bi bi-calculator"></i>
                </div>
                <div class="stat-title">Giá Trị Đơn Trung Bình (AOV)</div>
                <div class="stat-number text-warning">
                    <fmt:formatNumber value="${aov}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                </div>
            </div>
        </div>
    </div>

    <!-- Khối biểu đồ -->
    <div class="row g-4 mb-4">
        <!-- Biểu đồ doanh số ngày -->
        <div class="col-12 col-lg-8">
            <div class="custom-card">
                <div class="card-title-container">
                    <h5 class="custom-card-title"><i class="bi bi-graph-up text-warning me-2"></i>Biểu Đồ Xu Hướng Doanh Thu</h5>
                </div>
                <div style="height: 320px; position: relative;">
                    <canvas id="revenueLineChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Biểu đồ tỷ trọng sản phẩm bán chạy -->
        <div class="col-12 col-lg-4">
            <div class="custom-card">
                <div class="card-title-container text-center text-lg-start">
                    <h5 class="custom-card-title mb-0"><i class="bi bi-pie-chart-fill text-warning me-2"></i>Thống Kê Số Lượng Nước Bán Chạy</h5>
                    <small class="text-muted d-block mt-1" style="font-size: 0.78rem;">
                        <i class="bi bi-info-circle me-1"></i>Di chuột để xem % • Nhấp vào để mở to chi tiết
                    </small>
                </div>
                <div style="height: 310px; position: relative;" class="d-flex align-items-center justify-content-center mt-2">
                    <c:choose>
                        <c:when test="${not empty drinkQuantities or not empty catData}">
                            <canvas id="categoryPieChart"></canvas>
                        </c:when>
                        <c:otherwise>
                            <div class="text-muted text-center py-5">
                                <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                Không có dữ liệu thức uống trong khoảng thời gian này
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Bảng chi tiết báo cáo -->
    <div class="row">
        <div class="col-12">
            <div class="custom-card">
                <div class="card-title-container">
                    <h5 class="custom-card-title"><i class="bi bi-table text-warning me-2"></i>Bảng Tổng Hợp Chi Tiết Theo Ngày</h5>
                </div>
                <div class="table-responsive">
                    <table class="table custom-table align-middle">
                        <thead>
                            <tr>
                                <th>Ngày Báo Cáo</th>
                                <th class="text-center">Số Đơn Đã Giao</th>
                                <th class="text-end">Doanh Thu Ngày</th>
                                <th class="text-end">Doanh Thu TB / Đơn (AOV)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="stat" items="${dailyStats}">
                                <tr>
                                    <td><strong>${stat.date}</strong></td>
                                    <td class="text-center">${stat.orders} đơn</td>
                                    <td class="text-end text-success fw-bold">
                                        <fmt:formatNumber value="${stat.revenue}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                    <td class="text-end text-secondary">
                                        <fmt:formatNumber value="${stat.aov}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty dailyStats}">
                                <tr>
                                    <td colspan="4" class="text-center py-5 text-muted">
                                        <i class="bi bi-clipboard2-x fs-1 d-block mb-3"></i>
                                        Không tìm thấy dữ liệu hóa đơn nào trong khoảng thời gian đã chọn.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Phóng To Chi Tiết Món Bán Chạy -->
<div class="modal fade" id="drinkDetailModal" tabindex="-1" aria-labelledby="drinkDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header bg-dark text-white border-0 py-3 px-4">
                <h5 class="modal-title fw-bold text-warning" id="drinkDetailModalLabel">
                    <i class="bi bi-cup-hot-fill me-2"></i>Thống Kê Chi Tiết Món Bán Chạy
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4" style="background-color: #faf7f2;">
                <div class="row align-items-center g-4">
                    <!-- Cột Biểu Đồ Phóng To -->
                    <div class="col-12 col-md-6 text-center">
                        <div style="height: 280px; position: relative;" class="d-flex align-items-center justify-content-center">
                            <canvas id="enlargedDrinkChart"></canvas>
                        </div>
                        <p class="text-muted small mt-2 mb-0"><i class="bi bi-pie-chart me-1"></i>Biểu đồ biểu diễn tỷ trọng ly nước bán ra</p>
                    </div>
                    <!-- Cột Thông Số Chi Tiết -->
                    <div class="col-12 col-md-6">
                        <div class="card border-0 shadow-sm p-3 mb-3" style="border-radius: 12px; background: #ffffff;">
                            <div class="d-flex align-items-center">
                                <div class="bg-warning-subtle text-warning p-3 rounded-circle me-3">
                                    <i class="bi bi-cup-straw fs-3"></i>
                                </div>
                                <div>
                                    <small class="text-muted d-block">Tên sản phẩm / Thức uống</small>
                                    <h5 class="fw-bold text-dark mb-0" id="modalDrinkName">--</h5>
                                </div>
                            </div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <div class="card border-0 shadow-sm p-3 h-100" style="border-radius: 12px; background: #ffffff;">
                                    <small class="text-muted d-block mb-1"><i class="bi bi-box-seam text-primary me-1"></i>Số lượng bán</small>
                                    <span class="fs-4 fw-bold text-primary" id="modalDrinkQty">0 ly</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="card border-0 shadow-sm p-3 h-100" style="border-radius: 12px; background: #ffffff;">
                                    <small class="text-muted d-block mb-1"><i class="bi bi-percent text-success me-1"></i>Tỷ lệ bán chạy</small>
                                    <span class="fs-4 fw-bold text-success" id="modalDrinkPercent">0%</span>
                                </div>
                            </div>
                        </div>

                        <div class="card border-0 shadow-sm p-3" style="border-radius: 12px; background: #ffffff;">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-muted"><i class="bi bi-cash-stack text-warning me-1"></i>Doanh thu món này:</span>
                                <strong class="text-dark fs-6" id="modalDrinkRev">0 đ</strong>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted"><i class="bi bi-trophy text-danger me-1"></i>Thứ hạng bán chạy:</span>
                                <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold" id="modalDrinkRank">Hạng #1</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 px-4 py-3" style="background-color: #f0ebd8;">
                <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<!-- Tải thư viện vẽ biểu đồ Chart.js qua CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    const drinkLabels = [
        <c:forEach var="lbl" items="${drinkLabels}" varStatus="status">
            "${lbl}"${!status.last ? ',' : ''}
        </c:forEach>
    ];
    const drinkQuantities = [
        <c:forEach var="val" items="${drinkQuantities}" varStatus="status">
            ${val}${!status.last ? ',' : ''}
        </c:forEach>
    ];
    const drinkRevenues = [
        <c:forEach var="rev" items="${drinkRevenues}" varStatus="status">
            ${rev}${!status.last ? ',' : ''}
        </c:forEach>
    ];

    const chartColors = [
        '#8c6239', // Nâu cà phê đậm
        '#dcae82', // Nâu sữa nhạt
        '#5c8a67', // Xanh lục
        '#cf5b5b', // Đỏ san hô
        '#eba134', // Vàng cam
        '#3b82f6', // Xanh dương
        '#8b5cf6', // Tím
        '#ec4899'  // Hồng
    ];

    let enlargedChartInstance = null;

    function openDrinkDetailModal(index) {
        if (index < 0 || index >= drinkLabels.length) return;

        const drinkName = drinkLabels[index];
        const qty = drinkQuantities[index];
        const rev = drinkRevenues[index];
        const totalQty = drinkQuantities.reduce((a, b) => a + b, 0);
        const percent = totalQty > 0 ? ((qty / totalQty) * 100).toFixed(1) : 0;

        document.getElementById('modalDrinkName').innerText = drinkName;
        document.getElementById('modalDrinkQty').innerText = qty + ' ly';
        document.getElementById('modalDrinkPercent').innerText = percent + '%';
        document.getElementById('modalDrinkRev').innerText = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(rev);
        document.getElementById('modalDrinkRank').innerText = 'Hạng #' + (index + 1);

        const modalCtx = document.getElementById('enlargedDrinkChart').getContext('2d');
        
        if (enlargedChartInstance) {
            enlargedChartInstance.destroy();
        }

        const bgColors = drinkLabels.map((_, i) => i === index ? chartColors[i % chartColors.length] : 'rgba(210, 210, 210, 0.35)');
        const borderColors = drinkLabels.map((_, i) => i === index ? '#ffffff' : '#e0e0e0');
        const borderWidths = drinkLabels.map((_, i) => i === index ? 3 : 1);

        enlargedChartInstance = new Chart(modalCtx, {
            type: 'doughnut',
            data: {
                labels: drinkLabels,
                datasets: [{
                    data: drinkQuantities,
                    backgroundColor: bgColors,
                    borderColor: borderColors,
                    borderWidth: borderWidths
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: {
                    animateScale: true,
                    animateRotate: true
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const q = context.raw;
                                const p = totalQty > 0 ? ((q / totalQty) * 100).toFixed(1) : 0;
                                return ` ${context.label}: ${q} ly (${p}%)`;
                            }
                        }
                    }
                },
                cutout: '62%'
            }
        });

        const modal = new bootstrap.Modal(document.getElementById('drinkDetailModal'));
        modal.show();
    }

    document.addEventListener("DOMContentLoaded", function() {
        // --- 1. BIỂU ĐỒ ĐƯỜNG XU HƯỚNG DOANH THU ---
        const dailyLabels = [
            <c:forEach var="lbl" items="${chartLabels}" varStatus="status">
                "${lbl}"${!status.last ? ',' : ''}
            </c:forEach>
        ];
        const dailyData = [
            <c:forEach var="val" items="${chartData}" varStatus="status">
                ${val}${!status.last ? ',' : ''}
            </c:forEach>
        ];

        const lineCtx = document.getElementById('revenueLineChart').getContext('2d');
        
        const revenueGradient = lineCtx.createLinearGradient(0, 0, 0, 300);
        revenueGradient.addColorStop(0, 'rgba(235, 161, 52, 0.4)');
        revenueGradient.addColorStop(1, 'rgba(235, 161, 52, 0.0)');

        new Chart(lineCtx, {
            type: 'line',
            data: {
                labels: dailyLabels,
                datasets: [{
                    label: 'Doanh thu (đ)',
                    data: dailyData,
                    borderColor: '#eba134',
                    borderWidth: 3,
                    backgroundColor: revenueGradient,
                    fill: true,
                    tension: 0.35,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: '#eba134',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let label = context.dataset.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                if (context.parsed.y !== null) {
                                    label += new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                                }
                                return label;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: '#f0ebd8'
                        },
                        ticks: {
                            callback: function(value) {
                                return new Intl.NumberFormat('vi-VN', { notation: "compact", compactDisplay: "short" }).format(value) + 'đ';
                            }
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                }
            }
        });

        // --- 2. BIỂU ĐỒ TRÒN THỐNG KÊ SỐ LƯỢNG NƯỚC BÁN CHẠY ---
        if (drinkQuantities && drinkQuantities.length > 0) {
            const pieCtx = document.getElementById('categoryPieChart').getContext('2d');
            new Chart(pieCtx, {
                type: 'doughnut',
                data: {
                    labels: drinkLabels,
                    datasets: [{
                        data: drinkQuantities,
                        backgroundColor: chartColors,
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    onHover: (evt, activeElements) => {
                        const target = evt.native ? evt.native.target : null;
                        if (target) {
                            target.style.cursor = activeElements.length ? 'pointer' : 'default';
                        }
                    },
                    onClick: (evt, activeElements) => {
                        if (activeElements && activeElements.length > 0) {
                            const index = activeElements[0].index;
                            openDrinkDetailModal(index);
                        }
                    },
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                boxWidth: 12,
                                padding: 12,
                                font: {
                                    size: 11
                                }
                            }
                        },
                        tooltip: {
                            callbacks: {
                                title: function(context) {
                                    return context[0].label;
                                },
                                label: function(context) {
                                    const quantity = context.raw;
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = total > 0 ? ((quantity / total) * 100).toFixed(1) : 0;
                                    return [
                                        ` • Số lượng bán: ` + quantity + ` ly`,
                                        ` • Tỷ lệ bán chạy: ` + percentage + `%`
                                    ];
                                }
                            }
                        }
                    },
                    cutout: '62%'
                }
            });
        }
    });
</script>

<!-- Nhúng Footer dùng chung -->
<jsp:include page="common/footer.jsp" />
