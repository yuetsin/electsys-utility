cask 'electsys-utility' do
    version '0.9.9'
    sha256 :no_check
    url "https://github.com/yuetsin/electsys-utility/releases/download/v#{version}/Electsys.Utility.dmg"
    appcast 'https://github.com/yuetsin/electsys-utility/releases.atom'
    name 'Electsys Utility'
    homepage 'https://github.com/yuetsin/electsys-utility/'
    app 'Electsys Utility.app'
end