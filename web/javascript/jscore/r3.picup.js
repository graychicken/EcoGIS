
(function($, undefined) {
    $.fn.isMobileSafari = function() {
        var isMobile =  (
            (navigator.platform.indexOf("iPad") != -1) ||
            (navigator.platform.indexOf("iPhone") != -1) ||
            (navigator.platform.indexOf("iPod") != -1)
        );
        if (isMobile && navigator.userAgent.indexOf("AppleWebKit") != -1) {
            return true;
        } else {
            return false;
        }
    };
    
    $.fn.picupEncode = function(clear) {
        if (clear.substr(0, 2) == '$$') {
            return clear;
        }
        var coded = '$$';
        for (var i = 0; i < clear.length; i++) {
            switch (clear.substr(i, 1)) {
                case '&':
                    coded += '$6';
                    break;
                case '?':
                    coded += '$5';
                    break;
                case ' ':
                    coded += '$4';
                    break;
                case '=':
                    coded += '$3';
                    break;
                case '/':
                    coded += '$2';
                    break;
                case '\\':
                    coded += '$1';
                    break;
                case '$':
                    coded += '$0';
                    break;
                default:
                    coded += clear.substr(i, 1);
            }
        }
        return coded;
    };
    
    $.fn.picupDecode = function (noclear) {
        decoded = '';
        decoding = false;
        if (noclear.substr(0, 2) != '$$') {
            return noclear;
        } else {
            noclear = noclear.substr(2);
        }
        for (i = 0; i < noclear.length; i++) {
            if (decoding === false) {
                switch (noclear.substr(i, 1)) {
                    case '$':
                        decoding = true;
                        break;
                    default:
                        decoded += noclear.substr(i, 1);
                }
            } else {
                switch (noclear.substr(i, 1)) {
                    case '6':
                        decoded += '&';
                        decoding = false;
                        break;
                    case '5':
                        decoded += '?';
                        decoding = false;
                        break;
                    case '4':
                        decoded += ' ';
                        decoding = false;
                        break;
                    case '3':
                        decoded += '=';
                        decoding = false;
                        break;
                    case '2':
                        decoded += '/';
                        decoding = false;
                        break;
                    case '1':
                        decoded += '\\';
                        decoding = false;
                        break;
                    case '0':
                        decoded += '$';
                        decoding = false;
                        break;
                }
                decoding = false;
            }
        }
        return decoded;
    };
    
    $.widget('r3.r3picup', $.r3.r3core, {
        options: {
            //windowName: 'picup',
            callbackURL: null,
            debug: true,
            purpose: null,
            referrerfavicon: null,
            referrername: null,
            returnthumbnaildataurl: true
        },
        
        _create: function() {
            var self = this,
            element = self.element[0];
            
            // set window name
            /*self.setWindowName(self.options.windowName);*/
            
            // apply picup widget
            Picup.convertFileInput(element, self.options);
            Picup.callbackHandler = function(params){
                for(var key in params){
                    alert(key+' == '+params[key]);
                }
            }
        },
        
        /*
        setWindowName: function(name) {
            window.name = 'inspection_edit';
        },*/
        
        checkUpload: function() {
            if (window.location.hash != '') {
                var hash = window.location.hash.replace(/^\#/, '');
                var paramKVs = hash.split('&');
                var paramHash = {};
                for(var p=0;p<paramKVs.length;p++){
                        var kvp = paramKVs[p];
                        // we only want to split on the first =, since data:URLs can have = in them
                        var kv = kvp.replace('=', '&').split('&');
                        paramHash[kv[0]] = kv[1];
                }
                if (paramHash['status'] != 'Complete') {
                    alert("L'upload non è stato portato a termine");
                }
                document.title += 'a';
                if ('remoteImageURL' in paramHash) {
                document.title += 'b';

                    $('#mobile_safari_upload_url').val(paramHash['remoteImageURL']);
                    $('#user_feedback').html('<b>Immagine salvata su server remoto</b>');
                } else {
                document.title += 'c';
                    alert("nessun URL al server remoto");
                }
                document.title += 'd';
            }
        }
        
    });

    $.extend($.r3.r3picup, {
        version: "1.0.0"
    });
    
})(jQuery);