# ==========================================
# Tencent ACE One-Time Optimizer
# One-shot execution, no background
# ==========================================

# --- Admin check ---
$principal = New-Object Security.Principal.WindowsPrincipal `
    ([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    exit 1
}

# --- Config ---
$ProcessNames = @("SGuard64", "SGuardSvc64")
$CpuCount     = [Environment]::ProcessorCount

if ($CpuCount -lt 2) {
    exit 1
}

$LastCpuIndex = $CpuCount - 1
$AffinityMask = [IntPtr](1 -shl $LastCpuIndex)

# --- One-time processing ---
foreach ($Name in $ProcessNames) {

    $Processes = Get-Process -Name $Name -ErrorAction SilentlyContinue

    if ($Processes) {
        foreach ($Proc in $Processes) {
            try {
                $Proc.ProcessorAffinity = $AffinityMask
                $Proc.PriorityClass    = 'Idle'
            } catch {
                # ignore errors
            }
        }
    }
}

# --- Exit immediately ---
exit 0
