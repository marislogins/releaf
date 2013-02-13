jQuery(document).ready(function() {
    jQuery('.list[data-sortable]').sortable({
        axis: "y",
        ontainment: "parent",
        cursor: "move",
        delay: 150,
        distance: 5,
        handle: '> .handle',
        items: "> .item",
        scroll: true,
        update: function( event, ui ) {
            jQuery(this).trigger('sortableupdate');
        }
    });

    jQuery('[data-sortable]').on('sortableupdate', function() {
        var sortable_container = jQuery(this);
        sortable_container.find('> .item > input[type="hidden"].position').each(function(i) {
            jQuery(this).attr('value', i);
        });
    });

    jQuery( document.body ).on('itemadd', '.list[data-sortable]', function (e) {
        jQuery(e.target).trigger('sortableupdate');
    });

});