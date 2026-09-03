# Fedora Setup Guide

**Hardware:** Intel i7-8665U, 32GB RAM, Intel UHD 620, 931.5GB NVMe SSD

---

## 1. Bootable USB

```bash
lsblk                        # find USB device (e.g. /dev/sda)
sudo umount /media/$USER/Fedora*
sudo dd if=~/Downloads/Fedora-KDE-Desktop-Live-43-1.6.x86_64.iso of=/dev/sda bs=4M status=progress oflag=sync
sync
```

Use `/dev/sda` (whole device), NOT `/dev/sda1` (partition). Wrong device = data loss.

---

## 2. Partition Scheme

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Partition    Size      Mount         Filesystem  Flags    Notes           │
├─────────────────────────────────────────────────────────────────────────────┤
│  1. Root      148GB     /             ext4        -        System          │
│  2. EFI       512MB     /boot/efi     fat32       boot,esp UEFI boot      │
│  3. Boot      2GB       /boot         ext4        -        Kernels        │
│  4. Home      220GB     /home         ext4        -        User data      │
│  5. Swap      20GB      swap          swap        swap     Hibernation    │
│  6. Storage   539GB     /stuff        ext4        -        Data storage   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. KDE Installer Steps

### BEFORE installer:
1. Open KDE Partition Manager
2. Format 512MB EFI partition as FAT32
3. Set boot flag on EFI partition

### IN installer:
1. Select "Custom" partitioning
2. Delete old partitions (keep /stuff if preserving data)
3. Set mount points for ALL partitions:

```
Root (148GB)    → /            ext4
EFI (512MB)     → /boot/efi    fat32 (toggle reformat ON)
Boot (2GB)      → /boot        ext4
Home (220GB)    → /home        ext4
Swap (20GB)     → swap         (use "Custom" field)
Storage (539GB) → /stuff       (use "Custom" field)
```

If keeping /stuff data: set mount point to `/stuff`, **UNCHECK "Format"**

---

## 4. Post-Install

### System update
```bash
sudo dnf update -y && sudo dnf upgrade -y
```

### DNF config (`/etc/dnf/dnf.conf`)
```ini
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
```

### RPM Fusion
```bash
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### Multimedia codecs
```bash
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} \
  gstreamer1-plugin-openh264 gstreamer1-libav \
  --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install -y ffmpeg ffmpeg-libs
```

### Intel GPU fix — freeze / lid-close hang / screen corruption

These three kernel params fix a cluster of Intel UHD 620 (Whiskey Lake) display
issues on this laptop:
- Random GPU freezes
- **Lid-close hang** requiring a forced power-off
- **Garbled / "broken screen" colors** after suspend or resume

Symptom in logs: a flood of `i915 ... *ERROR* Atomic update failure on pipe A`
(check with `journalctl -b -1 -k | grep -c "Atomic update failure"`).

```
i915.enable_psr=0 i915.enable_fbc=0 intel_idle.max_cstate=1
```

**Fedora 44 method (BLS / `grubby`)** — this is the current, correct way. The old
`grub2-mkconfig` approach below does NOT work on F44's BLS bootloader.

```bash
# 1. Apply to all existing boot entries
sudo grubby --update-kernel=ALL \
  --args="i915.enable_psr=0 i915.enable_fbc=0 intel_idle.max_cstate=1"

# 2. Persist for future kernels (template for new kernel installs).
#    IMPORTANT: keep this on ONE line — a stray newline breaks kernel installs.
#    Verify afterwards with: cat -A /etc/kernel/cmdline  (one $ at the very end)
sudo cp /etc/kernel/cmdline /etc/kernel/cmdline.backup
sudo sed -i 's/[[:space:]]*$//; s|$| i915.enable_psr=0 i915.enable_fbc=0 intel_idle.max_cstate=1|' /etc/kernel/cmdline

# 3. Reboot, then verify the params are active:
cat /proc/cmdline | grep -o 'i915[^ ]*'   # expect enable_psr=0 and enable_fbc=0
```

Rollback: `sudo grubby --update-kernel=ALL --remove-args="i915.enable_psr=0 i915.enable_fbc=0 intel_idle.max_cstate=1"` and restore `/etc/kernel/cmdline` from the backup.

<details>
<summary>Old pre-F44 method (grub2-mkconfig) — kept for reference, do not use on F44</summary>

```bash
# Add to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub:
i915.enable_psr=0 i915.enable_fbc=0 intel_idle.max_cstate=1

sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
</details>

### CPU pinned at low clocks — turbo disabled by tuned's `powersave` profile

Symptoms show up all at once and are easy to misattribute to the browser, the network,
or a DNS/ad-blocker setup:
- Video playback stutters; Firefox's **Data Decoder** process spikes to ~90% CPU
- Image-heavy pages render jerkily
- General desktop sluggishness that survives every browser-side fix

Root cause: tuned's `powersave` profile sets `no_turbo=1` and caps `scaling_max_freq` to
the base clock. On the i7-8665U a **4800MHz turbo ceiling collapses to 1900MHz**, with
cores idling at 400–800MHz. Temperatures stay cool (~44°C), so it does **not** present as
thermal throttling — which is exactly why it gets missed.

The profile is normally set by `tuned-ppd` from the desktop's power-profile applet, so this
is usually reached by someone selecting "Power Saver" — not by editing tuned directly.

Diagnose:
```bash
tuned-adm active                                   # "powersave" is the culprit
cat /etc/tuned/active_profile                      # what gets restored at boot
busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles \
  net.hadess.PowerProfiles ActiveProfile           # the desktop setting driving it
cat /sys/devices/system/cpu/intel_pstate/no_turbo  # 1 = turbo OFF
grep -m1 "model name" /proc/cpuinfo                # note the chip's rated turbo clock
echo "cur=$(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)/1000))MHz"
echo "max=$(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)/1000))MHz"
sensors | grep -i "Package id 0"                   # cool temps = NOT thermal throttling
```

**Fix — set it in the desktop power UI, not with `tuned-adm`.**

On Fedora with `tuned-ppd` enabled (the default), the desktop power-profile daemon owns the
tuned profile: it writes `/etc/tuned/active_profile` from its own setting. A manual
`sudo tuned-adm profile balanced` therefore **does not stick** — it is silently reverted on
the next profile event or the next boot. Set **Balanced** in the desktop's power management
applet instead; that persists and propagates down to tuned.

The mapping lives in `/etc/tuned/ppd.conf`:
```bash
[profiles]
power-saver=powersave              # the bad state — turbo off, capped to base clock
balanced=balanced                  # what you want
performance=throughput-performance
```

Manual override, only if you do not want the desktop controlling it at all:
```bash
sudo systemctl disable --now tuned-ppd
sudo tuned-adm profile balanced    # now /etc/tuned/active_profile is authoritative
```

Verify — `no_turbo` flips to `0`, the ceiling jumps to the rated turbo clock, and real
clocks climb immediately:
```bash
cat /sys/devices/system/cpu/intel_pstate/no_turbo                                  # expect 0
echo "max=$(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)/1000))"  # expect 4800
echo "cur=$(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)/1000))"  # expect ~3000
cat /etc/tuned/active_profile                                                      # expect balanced
```

Measured on this laptop, all on AC (clocks and temps are under light desktop load — both
scale with what you are actually running):

| profile | turbo | ceiling | actual clock | package temp |
|---|---|---|---|---|
| `power-saver` → `powersave` | off | 1900MHz | ~900MHz | 44°C |
| `balanced` → `balanced` | on | 4800MHz | ~2900–3800MHz | 59°C |
| `performance` → `throughput-performance` | on | 4800MHz | ~4200MHz | 80°C |

**Prefer `balanced` over `performance`.** It costs ~25% clock for 21°C less heat and much
less fan noise, and software video decode never needed more than 3GHz — the stutter was at
900MHz. `balanced` is also the value of `default=` in `ppd.conf`, so if the daemon forgets
the choice at boot it lands on the same profile rather than degrading.

Three things that look wrong afterwards but are not:
- **`scaling_governor` still reads `powersave`.** That is `intel_pstate`'s default governor
  on Fedora and it scales all the way to turbo. Don't chase it.
- **`powerprofilesctl` may not be installed** even though the daemon is running. Read the
  active profile over D-Bus instead:
  ```bash
  busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles \
    net.hadess.PowerProfiles ActiveProfile
  ```
- **On battery the cap partly re-engages.** `ppd.conf` sets `battery_detection=true` and
  remaps `[battery] balanced=balanced-battery`. Plug in AC for sustained load.

`power-saver` is **not** battery-only — it engages and sticks on AC too. Observed here
running at ~900MHz while plugged in, for days, after a manual `tuned-adm` fix appeared to
work at the time. Always re-check `/etc/tuned/active_profile` rather than trusting that an
earlier fix held.

If `no_turbo` stays `1` after switching profiles, turbo is disabled in the BIOS instead —
check the firmware settings.

Rollback: set **Power Saver** in the desktop power applet (or
`sudo tuned-adm profile powersave` if you disabled `tuned-ppd`).

### Flatpak
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Dev tools
```bash
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y git curl wget vim neovim htop ripgrep fd-find fzf zsh tmux
```

### SSD trim + swap tuning
```bash
sudo systemctl enable --now fstrim.timer
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

### Hostname
```bash
sudo hostnamectl set-hostname your-hostname
```

### Konsole setup
```bash
# Install Nerd Font for icon support (required for LazyVim, Neovim, etc.)
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
rm JetBrainsMono.zip
fc-cache -fv
```

After installing:
1. **Restart Konsole** (close all windows and reopen)
2. Go to **Settings → Edit Current Profile... → Appearance**
3. Click **Choose...** under Font
4. Search for and select **JetBrainsMono Nerd Font Mono**
5. Click **OK**

Test icons display:
```bash
echo -e "\uf015 \ue7c5 \uf121 \uf09b"
```

### Hibernation setup

Enable hibernation by configuring GRUB to resume from swap partition.

> **⚠️ As of Fedora 44 (kernel 7.0+), the `intel_hid` blacklist is NO LONGER NEEDED.**
> The kernel 6.8 regression (bug 218634) that caused spurious wakeups during
> hibernation has been fixed upstream. Hibernation works cleanly on F44 with
> `intel_hid` loaded normally. The blacklist steps below are kept for historical
> reference / older kernels only — skip them on F44.
>
> If you previously blacklisted it, you can safely re-enable:
> ```bash
> sudo mv /etc/modprobe.d/blacklist-intel-hid.conf /etc/modprobe.d/blacklist-intel-hid.conf.disabled
> sudo dracut -f && sudo reboot
> # then test one cycle: sudo systemctl hibernate
> ```
> Note: the `resume=` kernel param and the dracut `resume` module below are the
> standard, required way to enable hibernation — those always stay.

**Historical note (kernel 6.8–6.x):** Kernel 6.8+ had a regression in the `intel_hid` driver that caused spurious wakeup events during hibernation on Dell/Intel laptops (Dell Latitude 7400 and similar). The blacklist below was the workaround.

**Bug reference:** https://bugzilla.kernel.org/show_bug.cgi?id=218634

**Method 1: Automated script (Recommended)**
```bash
cd ~/PycharmProjects/agentic-toolkit/tools-fedora/setup
./setup-hibernation.sh
```

**Method 2: Manual setup**

1. **Blacklist intel_hid module** (fixes kernel 6.8+ hibernation bug)
   ```bash
   sudo nano /etc/modprobe.d/blacklist-intel-hid.conf
   ```

   Add this content:
   ```
   # Blacklist intel_hid to prevent spurious wakeup events during hibernate
   # This fixes kernel 6.8+ regression causing "Wakeup event detected" errors
   # Bug: https://bugzilla.kernel.org/show_bug.cgi?id=218634
   blacklist intel_hid
   ```

   Save and exit (Ctrl+O, Enter, Ctrl+X)

2. **Identify swap partition**
   ```bash
   swapon --show
   # Look for /dev/nvme0n1p1 (20GB swap partition)
   ```

3. **Backup GRUB config**
   ```bash
   sudo cp /etc/default/grub /etc/default/grub.backup
   ```

4. **Edit GRUB configuration**
   ```bash
   sudo nano /etc/default/grub
   ```

   Change:
   ```
   GRUB_CMDLINE_LINUX="rhgb quiet"
   ```

   To (add `resume=/dev/nvme0n1p1`):
   ```
   GRUB_CMDLINE_LINUX="resume=/dev/nvme0n1p1 rhgb quiet"
   ```

   Or with Intel GPU fixes:
   ```
   GRUB_CMDLINE_LINUX="resume=/dev/nvme0n1p1 i915.enable_psr=0 i915.enable_fbc=0 intel_idle.max_cstate=1 rhgb quiet"
   ```

5. **Configure dracut for resume**
   ```bash
   echo 'add_dracutmodules+=" resume "' | sudo tee /etc/dracut.conf.d/resume.conf
   ```

6. **Rebuild initramfs**
   ```bash
   sudo dracut -f
   ```

7. **Update GRUB**
   ```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
   ```

8. **Reboot and test**
   ```bash
   sudo reboot

   # After reboot, verify intel_hid is not loaded:
   lsmod | grep intel_hid
   # Expected: No output (module is blacklisted)

   # Verify resume parameter:
   cat /proc/cmdline | grep resume

   # Test hibernation:
   sudo systemctl hibernate
   ```

**What you lose by blacklisting intel_hid:**
- Some vendor-specific hardware button handling (minimal impact)
- Most functions still work via other drivers (ACPI, desktop environment)

---

## 5. Apps

```bash
# PyCharm
cd ~/Downloads && tar -xzf pycharm-2025.3.2.tar.gz
~/Downloads/pycharm-2025.3.2/bin/pycharm

# Sublime Text
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf install -y sublime-text

# Thunderbird
sudo dnf install -y thunderbird

# Docker
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Chrome (optional)
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome
sudo dnf install -y google-chrome-stable

# Steam (requires RPM Fusion)
sudo dnf install -y steam
```

---

## 6. Distro Hopping

```
FORMAT:     / (148GB), /boot (2GB)
DON'T FORMAT: /home (220GB), /stuff (539GB)
BACKUP:     ~/.config, ~/.zshrc, ~/.p10k.zsh
```

---

## Troubleshooting

```bash
# Disk usage
sudo du -sh /* 2>/dev/null | sort -rh | head -10

# Clean space
sudo dnf clean all
docker system prune -a
flatpak uninstall --unused

# Hibernate test
sudo systemctl hibernate
free -h && swapon --show

# GPU freeze check
cat /proc/cmdline | grep i915

# CPU throttled? (no_turbo should be 0; cur should climb under load)
tuned-adm active
cat /etc/tuned/active_profile
cat /sys/devices/system/cpu/intel_pstate/no_turbo
echo "cur=$(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)/1000))MHz max=$(($(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)/1000))MHz"
```
