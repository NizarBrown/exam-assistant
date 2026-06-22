"""
RAG 考试助手 — 自动检索教材内容，让模型严格基于教材回答
用法: python chat_server.py [端口号]
"""
import http.server
import json
import os
import re
import sys
import urllib.request
import urllib.parse
from pathlib import Path

LLAMA_API = "http://127.0.0.1:8080/v1/chat/completions"
ROOT = Path(__file__).resolve().parent.parent
SUBJECTS_DIR = ROOT / "subjects"
MAX_CONTEXT = 1500   # 最多塞给模型的教材内容（中文字符），避免上下文溢出


class RAG:
    def __init__(self, subject_name):
        self.subject_name = subject_name
        self.docs_dir = SUBJECTS_DIR / subject_name / "docs"
        self.paragraphs = []  # [(filename, paragraph_text)]
        self._load()

    def _load(self):
        if not self.docs_dir.is_dir():
            return
        for fpath in sorted(self.docs_dir.glob("*.txt")):
            text = fpath.read_text(encoding="utf-8")
            # 按空行分段
            parts = re.split(r"\n\s*\n", text)
            for p in parts:
                p = p.strip()
                if len(p) > 20:  # 过滤太短的段
                    self.paragraphs.append((fpath.stem, p))

    def search(self, query, max_chars=MAX_CONTEXT):
        """简单关键词检索，返回最相关的段落"""
        keywords = list(set(query))  # 字级别匹配，中文友好
        scored = []
        for fname, para in self.paragraphs:
            score = sum(1 for c in keywords if c in para)
            # 更长的段落有更多匹配机会，用密度调整
            score = score / (len(para) ** 0.3)
            if score > 0:
                scored.append((score, fname, para))
        scored.sort(key=lambda x: x[0], reverse=True)

        result = []
        total = 0
        for _, fname, para in scored:
            chunk = f"【{fname}】\n{para}\n\n"
            if total + len(chunk) > max_chars:
                # 截断最后一段
                remaining = max_chars - total
                if remaining > 200:
                    result.append(f"【{fname}】\n{para[:remaining]}\n\n")
                break
            result.append(chunk)
            total += len(chunk)
        return "".join(result)


def get_subjects():
    if not SUBJECTS_DIR.is_dir():
        return []
    subjects = []
    for d in sorted(SUBJECTS_DIR.iterdir()):
        if d.is_dir() and not d.name.startswith("_") and not d.name.startswith("."):
            docs_dir = d / "docs"
            if docs_dir.is_dir() and list(docs_dir.glob("*.txt")):
                subjects.append(d.name)
    return subjects


class ChatHandler(http.server.BaseHTTPRequestHandler):
    rag_cache = {}
    subjects_cache = []

    def log_message(self, format, *args):
        pass  # 安静模式

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == "/" or path == "/chat.html":
            html_path = ROOT / "tools" / "chat.html"
            if html_path.is_file():
                self._serve_file(html_path, "text/html; charset=utf-8")
            else:
                self._json({"error": "chat.html not found"}, 404)
        elif path == "/api/subjects":
            self._json({"subjects": get_subjects()})
        else:
            self._json({"error": "not found"}, 404)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        data = json.loads(body)

        if self.path == "/api/chat":
            self._handle_chat(data)
        else:
            self._json({"error": "not found"}, 404)

    def _handle_chat(self, data):
        subject = data.get("subject", "")
        question = data.get("question", "")
        history = data.get("history", [])

        if not subject or not question:
            self._json({"error": "缺少 subject 或 question"}, 400)
            return

        # 初始化/复用 RAG
        if subject not in self.rag_cache:
            self.rag_cache[subject] = RAG(subject)
        rag = self.rag_cache[subject]

        # 检索相关教材内容
        context = rag.search(question)
        if not context:
            self._json({
                "answer": f"科目「{subject}」下未找到教材内容。\n请将 PDF 放入 subjects/{subject}/materials/ 后运行 tools/convert.bat 转换。",
                "sources": []
            })
            return

        # 构建消息
        system_msg = (
            "你是考试复习助手。请严格根据以下教材内容回答问题。\n"
            "如果教材中没有相关信息，请回答「教材中未找到相关内容」。\n"
            "不要使用教材以外的知识。回答时请注明引用的章节。\n"
            "数学公式请使用 LaTeX 格式，行内公式用 $...$，独立公式用 $$...$$。\n"
            "例如：$x^2 + y^2 = r^2$、$$\\frac{1}{n}\\sum_{i=1}^{n} x_i$$\n\n"
            "=== 教材内容 ===\n"
            + context
        )
        messages = [{"role": "system", "content": system_msg}]
        for h in history[-4:]:  # 最近 4 轮，避免溢出
            messages.append(h)
        messages.append({"role": "user", "content": question})

        # 调用 llama-server
        try:
            req = urllib.request.Request(
                LLAMA_API,
                data=json.dumps({
                    "messages": messages,
                    "temperature": 0.1,  # 低温度，减少胡编
                    "max_tokens": 1024,
                    "stream": False,
                }).encode("utf-8"),
                headers={"Content-Type": "application/json"},
            )
            resp = urllib.request.urlopen(req, timeout=120)
            result = json.loads(resp.read())
            answer = result["choices"][0]["message"]["content"]

            # 提取来源章节
            sources = list(set(
                re.findall(r'【(.+?)】', context)
            ))

            self._json({"answer": answer, "sources": sources})
        except Exception as e:
            self._json({"error": f"调用模型失败: {e}\n请确保 llama-server 已启动（端口 8080）"}, 500)

    def _serve_file(self, path, content_type):
        with open(path, "rb") as f:
            data = f.read()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", len(data))
        self.end_headers()
        self.wfile.write(data)

    def _json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", len(body))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
    server = http.server.HTTPServer(("127.0.0.1", port), ChatHandler)
    print(f"RAG 考试助手已启动: http://127.0.0.1:{port}")
    print(f"科目目录: {SUBJECTS_DIR}")
    subjects = get_subjects()
    if subjects:
        print(f"已加载科目: {', '.join(subjects)}")
    else:
        print("未找到科目，请在 subjects/ 下创建")
    server.serve_forever()


if __name__ == "__main__":
    main()
