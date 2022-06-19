#Requires -Version 5.1


function PSSyncle::Coalesce($a, $b) {
    if ($a) { $a } else { $b }
}

New-Alias "??" PSSyncle::Coalesce

function PSSyncle::Ternary($a, $b, $c) {
    if ($a) { $b } else { $c }
}

New-Alias "?:" PSSyncle::Ternary


function PSSyncle::ConditionalScriptBlockInvoke($a, $b = $null) {
    if ($a) {
        return $a.Invoke()
    } else {
        return $b
    }
}

New-Alias "?Invoke" PSSyncle::ConditionalScriptBlockInvoke
