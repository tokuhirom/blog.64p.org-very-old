(function () {

// top page
dispatcher('^/$', function () {
    $(function () {
        var disqus_shortname = 'blog64porg';

        var s = document.createElement('script'); s.async = true;
        s.type = 'text/javascript';
        s.src = 'http://' + disqus_shortname + '.disqus.com/count.js';
        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
    });
});

// entry page
dispatcher('^/entry/([0-9]+)$', function (match) {
    var entry_id = match[1];

    if (location.hash=="#disqus_thread") {
        $(function () {
                var disqus_shortname = 'blog64porg';
                var disqus_identifier = entry_id;
                var disqus_url = 'http://blog.64p.org' + location.pathname;

                var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
                dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
                (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        });
    }
});

// admin/add
dispatcher('^/admin/add', function () {
    $(function () {
        if (window.localStorage) {
            var textarea = $('textarea[name="body"]');
            var last;
            setInterval(function () {
                var body = textarea.val();
                if (body.length > 10) {
                    localStorage.setItem('add', body);
                }
            }, 1000);
        }
    });
});

function dispatcher (path, func) {
    dispatcher.path_func = dispatcher.path_func || []
    if (func) return dispatcher.path_func.push([path, func]);
    for(var i = 0, l = dispatcher.path_func.length; i < l; ++i) { // >
        var func = dispatcher.path_func[i];
        var match = path.match(func[0]);
        match && func[1](match);
    };
};
dispatcher(location.pathname);

})();
