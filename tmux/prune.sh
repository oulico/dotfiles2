#!/bin/sh
# 안전망: attach 안 된 세션 중 최근 활동 순으로 KEEP 개만 남기고 나머지를 정리한다.
# 이름이 main 인 세션은 attach 여부와 무관하게 절대 건드리지 않는다.
# 기본은 dry-run (대상만 로그). 실제 삭제는 --apply 를 줄 때만.

LOG="$HOME/.tmux/prune.log"
KEEP=5
PROTECT=main
APPLY=0
[ "$1" = "--apply" ] && APPLY=1

now=$(date '+%Y-%m-%d %H:%M:%S')
mode=dry-run
[ "$APPLY" = 1 ] && mode=apply

total=$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')
unatt=$(tmux list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^0$')
printf '%s [%s] run: sessions=%s unattached=%s keep=%s\n' "$now" "$mode" "$total" "$unatt" "$KEEP" >>"$LOG"

# 이름에 탭이 들어갈 일은 없다고 보고 탭으로 구분
tmux list-sessions -F '#{session_activity}	#{session_attached}	#{session_name}' 2>/dev/null |
  awk -F '\t' -v p="$PROTECT" '$2 == 0 && $3 != p' |
  sort -t "$(printf '\t')" -k1,1nr |
  tail -n +$((KEEP + 1)) |
  while IFS="$(printf '\t')" read -r act att name; do
    [ "$name" = "$PROTECT" ] && continue
    if [ "$APPLY" = 1 ]; then
      if tmux kill-session -t "=$name" 2>/dev/null; then r=killed; else r=failed; fi
    else
      r=would-kill
    fi
    printf '%s [%s] %s session=%s last_activity=%s\n' \
      "$now" "$mode" "$r" "$name" "$(date -r "$act" '+%Y-%m-%d %H:%M:%S')" >>"$LOG"
  done
exit 0
