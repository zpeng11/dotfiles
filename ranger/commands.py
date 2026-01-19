# -*- coding: utf-8 -*-
import os
import subprocess
import shlex
from ranger.api.commands import Command

class smart_l(Command):
    def execute(self):
        this_file = self.fm.thisfile
        
        if this_file.is_directory:
            # 如果是目录，正常进入
            self.fm.move(right=1)
        else:
            # 如果是文件且在 Tmux 环境中
            if 'TMUX' in os.environ:
                # 使用真正的 popup 窗口
                # -w 90% -h 90%：占据屏幕 90%
                # -E：命令结束时（nvim 退出）自动关闭窗口
                # -d "#{pane_current_path}"：保持在当前目录
                cmd = 'tmux display-popup -d "#{{pane_current_path}}" -w 95% -h 95% -E "nvim \'{}\'"'.format(this_file.path)
                self.fm.run(cmd, flags='f')
            else:
                # 如果没在 Tmux 里，正常打开 nvim
                self.fm.run('nvim "{}"'.format(this_file.path))

class smart_open(Command):
    def execute(self):
        this_file = self.fm.thisfile
        if this_file.is_directory:
            self.fm.move(right=1)
            return

        # 获取文件的绝对路径，作为唯一标识符
        file_path = os.path.abspath(this_file.path)
        
        if 'TMUX' not in os.environ:
            self.fm.run("nvim {}".format(shlex.quote(file_path)))
            return

        # 1. 查询当前 Tmux 会话中所有窗口的 ID 和它们绑定的自定义变量 @editing_file
        # 我们寻找是否有窗口的 @editing_file 变量等于当前的 file_path
        try:
            # list-windows -F 命令会输出类似: "%1 /home/user/test.py"
            output = subprocess.check_output(
                ['tmux', 'list-windows', '-F', '#{window_id} #{@editing_file}']
            )
            # Python 2/3 compatibility: decode if bytes
            if isinstance(output, bytes):
                output = output.decode('utf-8')
            output = output.splitlines()
        except subprocess.CalledProcessError:
            output = []

        target_window_id = None
        for line in output:
            parts = line.split(' ', 1)
            if len(parts) == 2:
                win_id, win_file = parts
                if win_file == file_path:
                    target_window_id = win_id
                    break

        # 2. 判断逻辑
        if target_window_id:
            # 情况 A：找到了已开启该文件的窗口，直接跳转过去
            subprocess.run(['tmux', 'select-window', '-t', target_window_id])
        else:
            # 情况 B：没有找到，开启新窗口
            window_name = "Edit: {}".format(os.path.basename(file_path))

            # 核心技巧：在创建窗口时，先用 tmux set-window-option 设置标签变量，再启动 nvim
            # 这样下次 L 进来时就能通过这个变量识别出来
            tmux_cmd = (
                "tmux new-window -n {} "
                "\"tmux set-window-option @editing_file {}; "
                "nvim {}\"".format(shlex.quote(window_name), shlex.quote(file_path), shlex.quote(file_path))
            )
            self.fm.run(tmux_cmd)
