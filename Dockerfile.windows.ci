# Temp Core Image
FROM microsoft/windowsservercore AS core

ENV RUBY_VERSION 2.2.4
ENV DEVKIT_VERSION 4.7.2
ENV DEVKIT_BUILD 20130224-1432

RUN mkdir C:\\tmp
ADD https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-${RUBY_VERSION}-x64.exe C:\\tmp
RUN C:\\tmp\\rubyinstaller-%RUBY_VERSION%-x64.exe /silent /dir="C:\Ruby_%RUBY_VERSION%_x64" /tasks="assocfiles,modpath"
ADD https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-64-${DEVKIT_VERSION}-${DEVKIT_BUILD}-sfx.exe C:\\tmp
RUN C:\\tmp\\DevKit-mingw64-64-%DEVKIT_VERSION%-%DEVKIT_BUILD%-sfx.exe -o"C:\DevKit" -y

# Final Nano Image
FROM microsoft/nanoserver AS nano

ENV RUBY_VERSION 2.2.4
ENV RUBYGEMS_VERSION 2.6.13
ENV BUNDLER_VERSION 1.15.4

COPY --from=core C:\\Ruby_${RUBY_VERSION}_x64 C:\\Ruby_${RUBY_VERSION}_x64
COPY --from=core C:\\DevKit C:\\DevKit

RUN setx PATH %PATH%;C:\DevKit\bin;C:\Ruby_%RUBY_VERSION%_x64\bin -m
RUN ruby C:\\DevKit\\dk.rb init
RUN echo - C:\\Ruby_%RUBY_VERSION%_x64 > C:\\config.yml
RUN ruby C:\\DevKit\\dk.rb install

RUN mkdir C:\\tmp
ADD https://rubygems.org/gems/rubygems-update-${RUBYGEMS_VERSION}.gem C:\\tmp
RUN gem install --local C:\tmp\rubygems-update-%RUBYGEMS_VERSION%.gem --no-ri --no-rdoc
RUN rmdir C:\\tmp /s /q

RUN update_rubygems --no-ri --no-rdoc
RUN gem install bundler --version %BUNDLER_VERSION% --no-ri --no-rdoc

ENTRYPOINT ["cmd", "/C"]
CMD [ "irb" ]
