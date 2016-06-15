
function serialize(object, maxDepth) {
function _processObject(object, maxDepth, level) {
        var output = Array()
        var pad = "  "
        if (maxDepth == undefined) {
            maxDepth = -1
        }
        if (level == undefined) {
            level = 0
        }
        var padding = Array(level + 1).join(pad)

        output.push((Array.isArray(object) ? "[" : "{"))
        var fields = Array()
        for (var key in object) {
            var keyText = Array.isArray(object) ? "" : ("\"" + key + "\": ")
            if (typeof (object[key]) == "object" && key != "parent" && maxDepth != 0) {
                var res = _processObject(object[key], maxDepth > 0 ? maxDepth - 1 : -1, level + 1)
                fields.push(padding + pad + keyText + res)
            } else {
                fields.push(padding + pad + keyText + "\"" + object[key] + "\"")
            }
        }
        output.push(fields.join(",\n"))
        output.push(padding + (Array.isArray(object) ? "]" : "}"))

        return output.join("\n")
    }

    return _processObject(object, maxDepth)
}


function formatString(string)
{
    var user_reg = "/@(\w*)/g";
    var tag_reg = "/#(\S*)/g"

    string = string.replace(/@(\w*)/g,'<a href="user://$1">@$1</a>');
    string = string.replace(/#(\S*)/g,'<a href="tag://$1">#$1</a>');

    return string;
}
