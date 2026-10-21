# fd 한도: macOS 기본 soft 256 을 tmux 서버가 물려받지 않게 한다.
# .zshrc 가 아니라 여기 두는 이유: ssh host '<cmd>' 처럼 SSH 앱이 명령을 직접 실행하면
# zsh -c 로 돌아 .zshrc/.zprofile 을 읽지 않고 .zshenv 만 읽는다.
# -S(soft) 만 올린다. zsh 의 ulimit -n 은 hard 까지 같이 바꿔서 되돌릴 수 없게 된다.
if [ "$(ulimit -Sn)" != unlimited ] && [ "$(ulimit -Sn)" -lt 4096 ]; then
  ulimit -Sn 4096 2>/dev/null
fi
