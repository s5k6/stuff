function() {

    function search(x) {
        while (x) {
            if (x.id) return x;
            x = x.previousElementSibling ?? x.parentElement;
        }
        return null;
    }

    const style = document.createElement('style');
    style.textContent = '* {\ncursor: crosshair !important;\n}\n';

    function handler(e) {
        e.preventDefault();
        e.stopPropagation();

        document.removeEventListener('click', handler, true);
        style.remove();

        const x = search(e.target);
        let url='';
        if (x) {
            location.hash = x.id;
            url = location.href;
        } else {
            history.replaceState(
                null, "", location.pathname + location.search
            );
        }
        navigator.clipboard.writeText(url).catch(() => { prompt(url); });

    }

    document.documentElement.appendChild(style);
    document.addEventListener('click', handler, true);
}
