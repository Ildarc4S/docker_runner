FROM ubuntu

# Устанавливаем базовые зависимости одной командой
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    valgrind \
    make \
    vim \
    check \
    lcov \
    gcovr \
    git \
    curl \
    zsh \
    cmake \
    gdb \
    wget \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Добавляем репозиторий LLVM для Ubuntu 22.04
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" > /etc/apt/sources.list.d/llvm.list

# Устанавливаем clang-format-18
RUN apt-get update && \
    apt-get install -y clang-format-18 && \
    ln -s /usr/bin/clang-format-18 /usr/bin/clang-format

# Устанавливаем Google Test
RUN apt-get update && apt-get install -y libgtest-dev && \
    cd /usr/src/gtest && \
    cmake CMakeLists.txt && \
    make && \
    cp lib/*.a /usr/lib && \
    ln -s /usr/include/gtest /usr/local/include/gtest

# Устанавливаем Oh My Zsh без переключения оболочки
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Копируем проект в контейнер
COPY . /project
WORKDIR /project

# Запускаем zsh по умолчанию
CMD ["zsh"]
