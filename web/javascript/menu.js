var R3MenuNavigateDefaultTarget = null;   /* The default menu target */

/**
 * Toggle the main menu item
 * param int id  the item id 
 */
function R3MenuShowHide(id) {
    $('#' + id).slideToggle(250);
}

function initMenu() {
    $('#main_menu_container li').each(function () {
        $(this).bind('mouseover', function (e) {
            $(this).addClass("menu_item_hover")
        })
                .bind('mouseout', function (e) {
                    $(this).removeClass("menu_item_hover")
                });
    });
}

/**
 * Unset all menù
 */
function resetAllMenu() {
    $('#main_menu_container li').each(function () {
        if ($(this).hasClass('menu_item_on')) {
            $(this).removeClass("menu_item_on menu_item_hover")
                    .addClass("menu_item_off")
                    .unbind('mouseover')
                    .bind('mouseover', function (e) {
                        $(this).addClass("menu_item_hover")
                    })
                    .unbind('mouseout')
                    .bind('mouseout', function (e) {
                        $(this).removeClass("menu_item_hover")
                    });
        }
    });
}

function autoCloseUnusedMenuGroup(usedItem) {
    $('#main_menu_container ul').each(function () {
        if ($(this).find('#' + usedItem).length == 0) {
            $(this).slideUp(250);
        }
    });
}

/**
 * Enable a men� item (and disable the old)
 * param object item    the item to activate
 */
function R3MenuSetActive(item) {
    resetAllMenu();
    $(item).addClass("menu_item_on")
    $(item).unbind('mouseout');

    if ($(item).length > 0) {
        autoCloseUnusedMenuGroup($(item)[0].id);
    }
}

/**
 * Enable a menù item by id (and disable the old)
 * param int item   the item id to activate
 */
function R3MenuSetActiveById(id) {
    R3MenuSetActive($('#' + id));
}

/**
 * Navigate to a new location
 * param object item      the menu item object
 * param string url       the new url
 * param string target    the navigation target
 */
function R3MenuNavigate(item, url, target) {

    ajaxWait(true);
    if (target == '_top') {
        document.location.href = url;
    } else {
        target = target || R3MenuNavigateDefaultTarget;
        if (target && target != '') {
            top.$('#' + target).attr('src', url);
        } else {
            document.location.href = url;
        }
    }
    R3MenuSetActive(item);
}

$(document).ready(function () {
    initMenu();
});