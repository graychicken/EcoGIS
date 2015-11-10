
(function($, undefined) {

    $.widget('r3.r3thumbnail', $.r3.r3core, {
        
        options: {
            doc_id: null,
            att_id: null,
            buttons: {},
            searchLayer: null,
            size: [260, 230],
            name:  'foto.jpg',
            title: 'foto',
            inplace: true,
            showPrimary: true,
            primaryId: null,            
            obj_id: null,
            obj_t: null,
            has_geom: false,
            isImage: false,
            attributes: {
                'date': '01/01/1970'
            },
            i18n: {
                'rotating' : "Ruotare la foto selezionata?",
                'primary' : "Vuoi veramente rendere questa foto principale? La foto verrà visualizzata nella scheda dell'oggetto.",
                'basicfoto': 'Principale'
            }
        },
        
        _create: function() {
            var self = this,
            element = self.element[0];
            
            // read customized foto id
            var doc_id = $(element).data('r3-doc_id');
            if (!isNaN(doc_id)) {
                self.options.doc_id = doc_id;
            }
            var att_id = $(element).data('r3-att_id');
            if (!isNaN(att_id)) {
                self.options.att_id = att_id;
            }
            var fotoName = $(element).data('r3-foto-name');
            if (fotoName != '') {
                self.options.name = fotoName;
            }
            
            
            var fotoTitle = $(element).data('r3-foto-title');
            self.options.title = fotoTitle;
            
            var fotoDate = $(element).data('r3-foto-date');
            self.options.attributes.date = fotoDate;
            
            var has_geom = $(element).data('r3-has-geom');
            if(has_geom == 1){
                self.options.has_geom = true;
            }
            
            var isPrimary = $(element).data('r3-is-primary');
            if(isPrimary == 1){
                if (!isNaN(doc_id)) {
                    self.options.primaryId = doc_id;
                }
            }
            
            var isImage = $(element).data('r3-is-image');
            if(isImage == 1){
                self.options.isImage = true;
            }
            
            var toolbar = $(element).find('.r3thumbnail_toolbar');
            var imageDiv = $(element).find('.r3image');
            
            if(self.options.inplace == false){
                self.options.inplace=0;
                self.options.embedded=1;                
            } else {
                self.options.inplace=1;
                self.options.embedded=0;
            }
            ;
            $(imageDiv).html("<a href='photo/document/"+self.options.doc_id+"/"+self.options.name+"' id='href_"+self.options.doc_id+"' rel='photo_gallery' ><img src='photo/document/"+self.options.doc_id+"/thumb/"+self.options.name+"' id='foto_"+self.options.doc_id+"' /></a>");
            $("#href_"+self.options.doc_id).attr('title', self.options.title);
            
            $(imageDiv).append("<img class='loading' id='loading_"+self.options.doc_id+"' src='../images/ajax_loader.gif' />");
            
            if(self.options.showPrimary == true && self.options.isImage == true){
                $(toolbar).prepend("<label for='primary"+doc_id+"'><input type='radio' name='primary' id='primary"+doc_id+"' value='primary"+doc_id+"'/>"+self.options.i18n.basicfoto+"</label>");
                $("#primary"+doc_id).change([self], self.primary);
                if(self.options.primaryId  == self.options.doc_id){
                    $("#primary"+doc_id).attr('checked', true);
                }
            }
            
            $.each(self.options.attributes, function(attrIndex, attrName) {
                $(toolbar).prepend("<div>"+attrName+"</div>");
            });
                
                
            $(toolbar).prepend("<h5>"+self.options.title+"</h5>");


            if (self.options.has_geom != true && self.options.buttons.map) {   
                delete  self.options.buttons.map;
            }
            
            if(self.options.isImage == false){
                delete self.options.buttons.rotate_90n;
                delete self.options.buttons.rotate_90;
                delete self.options.buttons.rotate_180;
            }
            
            
            $.each(self.options.buttons, function(buttonName, title) {
                $(toolbar).prepend("<img id='"+doc_id+"_"    +buttonName+"' title='"+title+"' src='../images/ico_"+buttonName+".gif' />");
            });
            
            $("#"+doc_id+"_edit").click([self], self.edit);
            $("#"+doc_id+"_del").click([self], self.del);
            $("#"+doc_id+"_map").click([self], self.map);
            $("#"+doc_id+"_download").click([self], self.download);
            
            $("#"+doc_id+"_rotate_90n").click([self, -90], self.rotate);
            $("#"+doc_id+"_rotate_90").click([self, 90], self.rotate);
            $("#"+doc_id+"_rotate_180").click([self, 180], self.rotate);
            
            self._trigger( "create", {}, {});
        },
        
        download: function(event) {
            var self = event.data[0];
            document.location.href = "photo/document/"+self.options.doc_id+"/"+self.options.name+"?disposition=download"
        },
        
        edit: function(event) {
            var self = event.data[0];
            
            url = 'edit.php?obj_t='+self.options.obj_t+'&doc_obj_id='+self.options.obj_id+'&embedded='+self.options.embedded+'&inplace='+self.options.inplace+'&act=mod&doc_id='+self.options.doc_id+'&att_is_image=true';
            
            if(self.options.inplace == false){
                OpenWindow(url, 'DOCUMENT', 850, 650);
            } else {
                location.href = url;
            }
        },
        
        del: function(event) {
            var self = event.data[0];
            url = 'edit.php?obj_t='+self.options.obj_t+'&doc_obj_id='+self.options.obj_id+'&embedded='+self.options.embedded+'&inplace='+self.options.inplace+'&act=del&doc_id='+self.options.doc_id+'&att_is_image=true';
            confirmDelete(url, 'Cancellare '+self.options.title+'?');
        },
        
        map: function(event) {
            var self = event.data[0];
            $.fn.zoomToMap({
                obj_t: self.options.obj_t, 
                obj_key: 'doc_id', 
                obj_id: self.options.obj_id, 
                highlight: true, 
                windowMode: true
            });
        },
        
        rotate: function(event) {
            var self = event.data[0];
            if (confirm(self.options.i18n.rotating)) {
                $("#loading_"+self.options.doc_id).show();
                $("#foto_"+self.options.doc_id).css('opacity', 0.4);
                if(self.options.showPrimary == true && self.options.primaryId == self.options.doc_id){ 
                    $("#foto_loading", top.document).show();
                    $("#foto", top.document).css('opacity', 0.4);
                }
                degree = event.data[1];
            
                $.getJSON('ajax.php', {
                    'obj_t': self.options.obj_t,
                    'method': 'rotate_image',  
                    'doc_id': self.options.doc_id, 
                    'doc_name': self.options.name,
                    'degree':degree
                },
                function(data) {
                    if (data.status == 0) {
                        var time = new Date();
                        //$("#foto_"+self.options.doc_id).attr('src', "photo/document/"+self.options.doc_id+"/thumb/"+self.options.name+"&time="+time.getTime());
                        $("#foto_"+self.options.doc_id).attr('src', "photo/document/"+self.options.doc_id+"/thumb/"+self.options.name+"&time="+time.getTime());
                        if(self.options.showPrimary == true && self.options.primaryId == self.options.doc_id){
                            $("#foto", top.document).attr('src', "photo/document/"+self.options.doc_id+"/thumb/"+self.options.name+"&time="+time.getTime());
                            $("#foto_loading", top.document).hide();
                            $("#foto", top.document).css('opacity', 1);
                        }
                        
                        
                    }
                    $("#foto_"+self.options.doc_id).css('opacity', 1);
                    $("#loading_"+self.options.doc_id).hide();
                });
            }
        },
        
        primary: function(event) {
            var self = event.data[0];
            if (confirm(self.options.i18n.primary)) {
                $.getJSON('ajax.php', {
                    'obj_t': self.options.obj_t,
                    'method': 'set_primary',  
                    'att_id': self.options.att_id
                },
                function(data) {                    
                    if (data.status == 0) {
                        self.options.primaryId = self.options.doc_id;
                        var time = new Date();
                        $('#foto_div', top.document).find('.error').hide();
                        $("#foto", top.document).attr('src', "photo/document/"+self.options.doc_id+"/thumb/"+self.options.name+"&time="+time.getTime());
                        $("a[rel=photo_gallery]", top.document).attr('src', "photo/document/"+self.options.doc_id+"/"+self.options.name+"&time="+time.getTime());
                        $(".cboxElement", top.document).attr('href', "photo/document/"+self.options.doc_id+"/"+self.options.name+"&time="+time.getTime());
                        $('#foto_div', top.document).find('[name=image]').show();
                        //$.r3.r3core.prototype.notify('info', "", 'I cambiamenti non saranno salvati finché il bottone Salva è cliccato.');

                    }
                });
            } else {
                //alert(self.options.primaryId);
                //$("#primary"+self.options.primaryId).attr('checked', true);
            }
        },
        
        _showLoading: function() {
            var self = this,
            element = self.element[0];
            
            var imgLoading = new Image();
            imgLoading.src = '../images/loading.gif';
            
            $(element).attr('src', imgLoading.src);
        },
        
        _refreshMap: function() {
            var self = this,
            element = self.element[0];
                
            var imgLoading = new Image();
            imgLoading.src = 'files/previewmap/'+self.options.searchLayer+'/'+self.options.searchField+'/'+self.options.searchValue+'/200x200-'+self.options.range+'x'+self.options.range+'.png';
            
            $(element).attr('src', imgLoading.src); // TODO: add eventually time
        }
        
    });

    $.extend($.r3.r3thumbnail, {
        version: "1.0.0"
    });
    
})(jQuery);
