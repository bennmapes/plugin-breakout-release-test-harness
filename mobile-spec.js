var path  = require('path'),
    fs    = require('fs'),
    shell = require('shelljs'),
    platforms = require('./platforms'),
    plugins   = require('./plugins'),
    cwd       = process.cwd(),
    results   = path.join(__dirname, 'results.json'),
    temp_dir  = path.join(__dirname, 'temp'),
    platforms_dir = path.join(temp_dir, 'platforms'),
    plugins_dir   = path.join(temp_dir, 'plugins'),
    projects_dir  = path.join(temp_dir, 'projects'),
    mobile_spec_dir = path.join(temp_dir, 'cordova-mobile-spec');

var ms_url  = 'https://git-wip-us.apache.org/repos/asf/cordova-mobile-spec.git';


module.exports = {
    'wp7' : function(project_path) {
        clone_mobile_spec();
        var www = path.join(project_path, 'www');
        shell.rm('-rf', path.join(www, 'js'));
        shell.rm('-rf', path.join(www, 'img'));
        shell.rm('-rf', path.join(www, 'css'));
        shell.rm('-rf', path.join(www, 'index.html'));
        var mobile_spec_files = fs.readdirSync(mobile_spec_dir);
        for(element in mobile_spec_files) {
            if(mobile_spec_files[element] != 'cordova.js') {
                shell.cp('-r', path.join(mobile_spec_dir, mobile_spec_files[element]), www);
            }
        }
    }
};

function clone_mobile_spec() {
    if(!fs.existsSync(mobile_spec_dir)) {
        console.log('Cloning Mobile Spec...');
        process.chdir(temp_dir);
        var cmd = 'git clone ' + ms_url;
        var result = shell.exec(cmd, {silent:true, async:false});
        if(result.code > 0) {
            console.log('Failed to clone cordova-mobile-spec.');
            console.log(output);
        }
    }
}