/**
 * Order Auto Notifier & Live Refresh Script (Ultra-Fast 0.8s Polling)
 * Tự động kiểm tra đơn hàng mới với tốc độ siêu nhanh (0.8s), phát âm thanh thông báo và làm mới dữ liệu tức thì cho cả Admin và Nhân viên.
 */
(function() {
    let lastOrderId = 0;
    let lastActiveCount = -1;
    let lastPendingCount = -1;
    let lastStatusHash = -1;
    let isInitialFetch = true;
    let pollInterval = 3000; // Tốc độ kiểm tra 3.0 giây / lần (Tối ưu hóa tránh nghẽn CSDL)
    let contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1)) || '';

    // Khởi tạo Toast container ở góc phải trên
    function initToastContainer() {
        if (!document.getElementById('orderToastContainer')) {
            const container = document.createElement('div');
            container.id = 'orderToastContainer';
            container.className = 'toast-container position-fixed top-0 end-0 p-3';
            container.style.zIndex = '9999';
            document.body.appendChild(container);
        }
    }

    // Phát âm thanh thông báo "Ting-ting 🔔" qua Web Audio API
    function playChimeSound() {
        try {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (!AudioContext) return;
            const audioCtx = new AudioContext();
            
            // Note 1 (D5 - 587.33Hz)
            const osc1 = audioCtx.createOscillator();
            const gain1 = audioCtx.createGain();
            osc1.type = 'sine';
            osc1.frequency.setValueAtTime(587.33, audioCtx.currentTime);
            gain1.gain.setValueAtTime(0.35, audioCtx.currentTime);
            gain1.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.25);
            osc1.connect(gain1);
            gain1.connect(audioCtx.destination);
            osc1.start();
            osc1.stop(audioCtx.currentTime + 0.25);

            // Note 2 (A5 - 880Hz)
            setTimeout(() => {
                const osc2 = audioCtx.createOscillator();
                const gain2 = audioCtx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(880, audioCtx.currentTime);
                gain2.gain.setValueAtTime(0.45, audioCtx.currentTime);
                gain2.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.4);
                osc2.connect(gain2);
                gain2.connect(audioCtx.destination);
                osc2.start();
                osc2.stop(audioCtx.currentTime + 0.4);
            }, 120);
        } catch (e) {
            console.log('Audio autoplay prevented:', e);
        }
    }

    // Hiển thị thông báo Toast nổi ở góc phải trên màn hình
    function showNotificationToast(order) {
        initToastContainer();
        const container = document.getElementById('orderToastContainer');

        const toastId = 'toast-order-' + order.id + '-' + Date.now();
        const formattedTotal = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(order.total);

        const toastHTML = `
            <div id="${toastId}" class="toast align-items-center text-bg-warning border-0 shadow-lg mb-2" role="alert" aria-live="assertive" aria-atomic="true" style="border-radius: 12px; font-family: system-ui, sans-serif;">
                <div class="d-flex p-3">
                    <div class="fs-2 me-3 d-flex align-items-center">
                        <i class="bi bi-bell-fill text-dark animate__animated animate__swing"></i>
                    </div>
                    <div class="toast-body p-0 flex-grow-1 text-dark">
                        <div class="fw-bold fs-6 mb-1">🔔 CÓ ĐƠN HÀNG MỚI #${order.id}</div>
                        <div class="small fw-semibold mb-1">Khách hàng: <strong>${order.customer}</strong> (${order.type})</div>
                        <div class="badge bg-dark text-warning fs-7">${formattedTotal} • ${order.time}</div>
                    </div>
                    <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        `;

        container.insertAdjacentHTML('beforeend', toastHTML);
        const toastEl = document.getElementById(toastId);
        if (window.bootstrap && bootstrap.Toast) {
            const bsToast = new bootstrap.Toast(toastEl, { delay: 6000 });
            bsToast.show();
        } else {
            toastEl.style.display = 'block';
            setTimeout(() => { toastEl.remove(); }, 6000);
        }
    }

    // Cập nhật các huy hiệu (Badge) số lượng đơn chờ ở header/sidebar
    function updateBadges(pendingCount, activeCount) {
        const count = activeCount !== undefined ? activeCount : pendingCount;
        if (count === undefined) return;
        const badges = document.querySelectorAll('.order-pending-badge, #pendingOrderBadge');
        badges.forEach(b => {
            b.textContent = count;
            if (count > 0) {
                b.style.display = 'inline-block';
            } else {
                b.style.display = 'none';
            }
        });
    }

    // Tự động làm mới dữ liệu danh sách đơn hàng tức thì (100ms) khi không có modal đang mở
    function triggerAutoRefresh() {
        const path = window.location.pathname;
        if (path.includes('/staff/orders') || path.includes('/admin/invoices') || path.includes('/admin/dashboard')) {
            // Đảm bảo không tự làm mới trang khi người dùng đang mở Modal thao tác
            const activeModal = document.querySelector('.modal.show');
            if (activeModal) return;

            setTimeout(() => {
                window.location.reload();
            }, 100);
        }
    }

    // Hàm gọi API polling ngầm
    function pollNewOrders() {
        const url = contextPath + '/api/orders/poll?lastOrderId=' + lastOrderId;

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (isInitialFetch) {
                    lastOrderId = data.maxOrderId || 0;
                    lastActiveCount = data.activeCount !== undefined ? data.activeCount : -1;
                    lastPendingCount = data.pendingCount !== undefined ? data.pendingCount : -1;
                    lastStatusHash = data.statusHash !== undefined ? String(data.statusHash) : "";
                    isInitialFetch = false;
                    updateBadges(data.pendingCount, data.activeCount);
                    return;
                }

                let shouldRefresh = false;

                // 1. Kiểm tra nếu có đơn hàng mới được tạo (Mã đơn tăng)
                if (data.maxOrderId > lastOrderId) {
                    lastOrderId = data.maxOrderId;
                    shouldRefresh = true;

                    if (data.hasNew && data.newOrders && data.newOrders.length > 0) {
                        playChimeSound();
                        data.newOrders.forEach(order => {
                            showNotificationToast(order);
                        });
                    }
                }

                // 2. Kiểm tra nếu số lượng đơn chưa hoàn thành hoặc số đơn chờ thanh toán thay đổi
                if (data.activeCount !== undefined && lastActiveCount !== -1 && data.activeCount !== lastActiveCount) {
                    lastActiveCount = data.activeCount;
                    shouldRefresh = true;
                }

                if (data.pendingCount !== undefined && lastPendingCount !== -1 && data.pendingCount !== lastPendingCount) {
                    lastPendingCount = data.pendingCount;
                    shouldRefresh = true;
                }

                // 3. Kiểm tra nếu có bất kỳ đơn nào thay đổi trạng thái (chuyển sang Đã giao món, Đang chế biến, v.v.)
                if (data.statusHash !== undefined && lastStatusHash !== "" && String(data.statusHash) !== lastStatusHash) {
                    lastStatusHash = String(data.statusHash);
                    shouldRefresh = true;
                }

                updateBadges(data.pendingCount, data.activeCount);

                if (shouldRefresh) {
                    triggerAutoRefresh();
                }
            })
            .catch(err => {
                // Ignore network error silently
            });
    }

    // Bắt đầu vòng lặp Polling khi DOM sẵn sàng
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            pollNewOrders();
            setInterval(pollNewOrders, pollInterval);
        });
    } else {
        pollNewOrders();
        setInterval(pollNewOrders, pollInterval);
    }
})();
