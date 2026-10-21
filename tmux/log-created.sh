#!/bin/sh
# session-created 훅에서 호출. 세션을 만든 주체를 ~/.tmux/created.log 에 남긴다.
# 사용: log-created.sh <session_name> <server_pid> <hook_client>
# 클라이언트가 이미 사라졌어도 첫 줄(시각·세션 이름)은 반드시 남도록 먼저 기록한다.
#
# 주의: 훅 안의 #{client_pid} 는 생성한 클라이언트가 아니라 "가장 최근 attach 된"
# 클라이언트로 풀리므로 쓰지 않는다. 대신 생성자를 두 경로로 찾는다.
#  - attached: 새 세션에 붙어 있는 클라이언트 (tmux new, tmux -CC new 등)
#  - detached: 지금 살아 있는, 어디에도 attach 안 된 tmux 클라이언트 프로세스 (tmux new -d 등)

LOG="$HOME/.tmux/created.log"
sess=${1:-?}
spid=${2:-}
hclient=${3:-}
now=$(date '+%Y-%m-%d %H:%M:%S')

# 1) 최소 기록: 무엇이 실패하더라도 이 줄은 남는다
printf '%s session=%s hook_client=%s\n' "$now" "$sess" "${hclient:-n/a}" >>"$LOG"

# pid 의 조상 중에 $2 가 있으면 0
has_ancestor() {
  p=$1
  while [ -n "$p" ] && [ "$p" -gt 1 ]; do
    [ "$p" = "$2" ] && return 0
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
  done
  return 1
}

# 계보 출력: pid → 부모 → ... (최대 6단계, launchd 에서 멈춤)
lineage() {
  pid=$1
  i=0
  while [ "$i" -lt 6 ] && [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    line=$(ps -o pid=,ppid=,user=,command= -p "$pid" 2>/dev/null)
    if [ -z "$line" ]; then
      printf '      pid %s: (already exited)\n' "$pid" >>"$LOG"
      return
    fi
    printf '      %s\n' "$line" | cut -c1-300 >>"$LOG"
    pid=$(printf '%s\n' "$line" | awk '{ print $2 }')
    i=$((i + 1))
  done
}

found=0

# 2) attach 된 생성자
for c in $(tmux list-clients -t "=$sess" -F '#{client_pid}:#{client_control_mode}' 2>/dev/null); do
  printf '    creator(attached, control_mode=%s) pid=%s\n' "${c#*:}" "${c%%:*}" >>"$LOG"
  lineage "${c%%:*}"
  found=1
done

# 3) detach 상태 생성자 후보: 서버도, attach 된 클라이언트도, 서버 자식(run-shell 등)도 아닌 tmux 프로세스
if [ "$found" = 0 ]; then
  attached=" $(tmux list-clients -F '#{client_pid}' 2>/dev/null | tr '\n' ' ') "
  for p in $(pgrep -x tmux 2>/dev/null); do
    [ "$p" = "$spid" ] && continue
    case "$attached" in *" $p "*) continue ;; esac
    [ -n "$spid" ] && has_ancestor "$p" "$spid" && continue
    printf '    creator(detached-candidate) pid=%s\n' "$p" >>"$LOG"
    lineage "$p"
    found=1
  done
fi

[ "$found" = 0 ] && printf '    creator: not found (client already exited)\n' >>"$LOG"

# 4) 생성자가 세션에 남긴 지문: update-environment 로 복사된 생성 클라이언트의 환경,
#    시작 디렉터리, 첫 pane 의 시작 명령 (session-created 는 비동기라 detach 생성자는 대개 이미 종료됨)
tmux display -p -t "=$sess:" '    hints: id=#{session_id} path=#{session_path} start_cmd=#{pane_start_command}' >>"$LOG" 2>/dev/null
tmux show-environment -t "=$sess" 2>/dev/null |
  grep -E '^(SSH_CONNECTION|SSH_TTY|TERM_PROGRAM|TERM)=' |
  sed 's/^/    env: /' >>"$LOG"
exit 0
