/**
 * Neofetch ASCII Art Setter — Client-side Application Logic
 * Handles: editor, live preview, particle animation, and server communication
 */

(function () {
    'use strict';

    // ===== DOM Elements =====
    const asciiInput = document.getElementById('asciiInput');
    const lineNumbers = document.getElementById('lineNumbers');
    const charCount = document.getElementById('charCount');
    const lineCount = document.getElementById('lineCount');
    const asciiPreview = document.getElementById('asciiPreview');
    const previewEmpty = document.getElementById('previewEmpty');
    const colorScheme = document.getElementById('colorScheme');
    const btnDone = document.getElementById('btnDone');
    const btnClear = document.getElementById('btnClear');
    const btnPaste = document.getElementById('btnPaste');
    const btnReset = document.getElementById('btnReset');
    const btnDismiss = document.getElementById('btnDismiss');
    const btnErrorDismiss = document.getElementById('btnErrorDismiss');
    const successOverlay = document.getElementById('successOverlay');
    const errorOverlay = document.getElementById('errorOverlay');
    const errorMessage = document.getElementById('errorMessage');
    const headerStatus = document.getElementById('headerStatus');
    const bgParticles = document.getElementById('bgParticles');

    // ===== Particles =====
    function createParticles() {
        const count = 30;
        for (let i = 0; i < count; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.left = Math.random() * 100 + '%';
            particle.style.animationDelay = Math.random() * 8 + 's';
            particle.style.animationDuration = (6 + Math.random() * 6) + 's';
            particle.style.width = particle.style.height = (1 + Math.random() * 2) + 'px';

            // Randomize colors between purple and cyan
            const colors = ['#a78bfa', '#06b6d4', '#34d399', '#8b5cf6'];
            particle.style.background = colors[Math.floor(Math.random() * colors.length)];

            bgParticles.appendChild(particle);
        }
    }

    createParticles();

    // ===== Line Numbers =====
    function updateLineNumbers() {
        const lines = asciiInput.value.split('\n');
        const count = lines.length || 1;
        let html = '';
        for (let i = 1; i <= count; i++) {
            html += i + '\n';
        }
        lineNumbers.textContent = html;
    }

    // ===== Stats =====
    function updateStats() {
        const text = asciiInput.value;
        const chars = text.length;
        const lines = text ? text.split('\n').length : 0;
        charCount.textContent = chars + ' char' + (chars !== 1 ? 's' : '');
        lineCount.textContent = lines + ' line' + (lines !== 1 ? 's' : '');
    }

    // ===== Preview =====
    function updatePreview() {
        const text = asciiInput.value;

        if (text.trim() === '') {
            previewEmpty.classList.remove('hidden');
            asciiPreview.classList.add('hidden');
            btnDone.disabled = true;
        } else {
            previewEmpty.classList.add('hidden');
            asciiPreview.classList.remove('hidden');
            // HTML-escape the text to prevent XSS and preserve characters
            asciiPreview.textContent = text;
            btnDone.disabled = false;
        }
    }

    // ===== Color Scheme =====
    function updateColor() {
        // Remove all color classes
        asciiPreview.className = 'ascii-preview';
        asciiPreview.classList.add('color-' + colorScheme.value);
        if (asciiInput.value.trim() === '') {
            asciiPreview.classList.add('hidden');
        }
    }

    // ===== Sync scroll for line numbers =====
    function syncScroll() {
        lineNumbers.scrollTop = asciiInput.scrollTop;
    }

    // ===== Status Indicator =====
    function setStatus(text, type) {
        const statusDot = headerStatus.querySelector('.status-dot');
        const statusText = headerStatus.querySelector('.status-text');
        statusText.textContent = text;

        headerStatus.className = 'header-status';
        statusDot.style.animation = 'none';

        switch (type) {
            case 'success':
                headerStatus.style.background = 'rgba(52, 211, 153, 0.12)';
                headerStatus.style.color = '#34d399';
                statusDot.style.background = '#34d399';
                statusDot.style.animation = 'pulse 2s infinite';
                break;
            case 'loading':
                headerStatus.style.background = 'rgba(251, 191, 36, 0.12)';
                headerStatus.style.color = '#fbbf24';
                statusDot.style.background = '#fbbf24';
                statusDot.style.animation = 'pulse 0.8s infinite';
                break;
            case 'error':
                headerStatus.style.background = 'rgba(248, 113, 113, 0.12)';
                headerStatus.style.color = '#f87171';
                statusDot.style.background = '#f87171';
                break;
            default:
                headerStatus.style.background = 'rgba(52, 211, 153, 0.12)';
                headerStatus.style.color = '#34d399';
                statusDot.style.background = '#34d399';
                statusDot.style.animation = 'pulse 2s infinite';
        }
    }

    // ===== API Communication =====
    async function setAsciiArt(asciiText) {
        const response = await fetch('/api/set-ascii', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ ascii: asciiText })
        });

        if (!response.ok) {
            const data = await response.json().catch(() => ({}));
            throw new Error(data.error || 'Server returned ' + response.status);
        }

        return response.json();
    }

    async function resetAsciiArt() {
        const response = await fetch('/api/reset-ascii', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });

        if (!response.ok) {
            const data = await response.json().catch(() => ({}));
            throw new Error(data.error || 'Server returned ' + response.status);
        }

        return response.json();
    }

    // ===== Event Handlers =====

    // Input events
    asciiInput.addEventListener('input', function () {
        updateLineNumbers();
        updateStats();
        updatePreview();
    });

    asciiInput.addEventListener('scroll', syncScroll);

    // Color scheme change
    colorScheme.addEventListener('change', updateColor);

    // Clear button
    btnClear.addEventListener('click', function () {
        asciiInput.value = '';
        updateLineNumbers();
        updateStats();
        updatePreview();
        asciiInput.focus();
    });

    // Paste button
    btnPaste.addEventListener('click', async function () {
        try {
            const text = await navigator.clipboard.readText();
            asciiInput.value = text;
            updateLineNumbers();
            updateStats();
            updatePreview();
        } catch (err) {
            // Fallback: focus textarea so user can Ctrl+V
            asciiInput.focus();
        }
    });

    // Done button — SET the ASCII art
    btnDone.addEventListener('click', async function () {
        const text = asciiInput.value.trim();
        if (!text) return;

        btnDone.classList.add('loading');
        setStatus('Saving…', 'loading');

        try {
            await setAsciiArt(text);
            setStatus('Art saved!', 'success');
            successOverlay.classList.add('visible');
        } catch (err) {
            setStatus('Error', 'error');
            errorMessage.textContent = err.message;
            errorOverlay.classList.add('visible');
        } finally {
            btnDone.classList.remove('loading');
        }
    });

    // Reset button — restore default neofetch
    btnReset.addEventListener('click', async function () {
        btnReset.classList.add('loading');
        setStatus('Resetting…', 'loading');

        try {
            await resetAsciiArt();
            setStatus('Reset to default', 'success');
            asciiInput.value = '';
            updateLineNumbers();
            updateStats();
            updatePreview();

            // Brief success flash
            successOverlay.querySelector('h2').textContent = 'Reset Complete!';
            successOverlay.querySelector('p').textContent = 'Neofetch is back to its default ASCII art.';
            successOverlay.classList.add('visible');
        } catch (err) {
            setStatus('Error', 'error');
            errorMessage.textContent = err.message;
            errorOverlay.classList.add('visible');
        } finally {
            btnReset.classList.remove('loading');
        }
    });

    // Dismiss overlays
    btnDismiss.addEventListener('click', function () {
        successOverlay.classList.remove('visible');
        // Restore success card text for next use
        setTimeout(function () {
            successOverlay.querySelector('h2').textContent = 'ASCII Art Set!';
            successOverlay.querySelector('p').textContent = 'Your custom art is now the neofetch logo.';
        }, 400);
    });

    btnErrorDismiss.addEventListener('click', function () {
        errorOverlay.classList.remove('visible');
    });

    // Close overlays on background click
    successOverlay.addEventListener('click', function (e) {
        if (e.target === successOverlay) btnDismiss.click();
    });

    errorOverlay.addEventListener('click', function (e) {
        if (e.target === errorOverlay) btnErrorDismiss.click();
    });

    // Keyboard shortcuts
    document.addEventListener('keydown', function (e) {
        // Escape to close overlays
        if (e.key === 'Escape') {
            successOverlay.classList.remove('visible');
            errorOverlay.classList.remove('visible');
        }

        // Ctrl+Enter to submit
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
            if (!btnDone.disabled) {
                btnDone.click();
            }
        }
    });

    // Tab key support in textarea (insert actual tab)
    asciiInput.addEventListener('keydown', function (e) {
        if (e.key === 'Tab') {
            e.preventDefault();
            const start = this.selectionStart;
            const end = this.selectionEnd;
            this.value = this.value.substring(0, start) + '    ' + this.value.substring(end);
            this.selectionStart = this.selectionEnd = start + 4;
            updateLineNumbers();
            updateStats();
            updatePreview();
        }
    });

    // ===== Initialize =====
    updateLineNumbers();
    updateStats();
    updatePreview();
    updateColor();
    setStatus('Ready', 'success');

})();
