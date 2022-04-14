module wopwop2aam;

import netcdf;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.getopt;
import std.file;
import std.math;
import std.path;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

import wopwopd.namelist;

struct Dataset {
	float speed;
	float flight_path_angle;
	float tilt_angle;
	float sphere_radius;
	Channel[] channels;

	@nogc uint hash() {
		import std.digest.murmurhash : MurmurHash3;
		import std.bitmanip : read, write, Endian;
		ubyte[12] buff;

		buff[].write!float(flight_path_angle, 0);
		buff[].write!float(speed, 4);
		buff[].write!float(tilt_angle, 8);

		auto hashfunc = MurmurHash3!(uint.sizeof*8, 64)();

		hashfunc.put(buff);
		
		auto _hash = hashfunc.finish;
		// well aint this the dumbest shit. Need for read to work
		ubyte[] hash = _hash[];

		return hash.read!uint;
	}
}

struct Function {
	float[] data;
}

struct Channel {
	
	float[] frequency;
	Function[] functions;
}

auto read_dataset(string dir, double fpa, double speed, double tilt_angle, double sphere_radius) {
	int[] header_buffer = new int[4];

	auto spectrum_file = File(dir.buildPath("spl_spectrum.fn"), "rb");
	scope(exit) spectrum_file.close;

	Dataset dataset;

	dataset.speed = speed;
	dataset.flight_path_angle = fpa;
	dataset.tilt_angle = tilt_angle;
	dataset.sphere_radius = sphere_radius;

	header_buffer = spectrum_file.rawRead(header_buffer);

	int i_max = header_buffer[0];
	int j_max = header_buffer[1];
	int samples = header_buffer[2];
	int functions = header_buffer[3];

	writeln("i_max: ", i_max);
	writeln("j_max: ", j_max);
	writeln("samples: ", samples);
	writeln("functions: ", functions);

	size_t total_obs = i_max*j_max;

	dataset.channels = new Channel[total_obs];

	foreach(ref channel; dataset.channels) {
		channel.frequency = new float[samples];
		channel.functions = new Function[functions - 1];
		foreach(ref func; channel.functions) {
			func.data = new float[samples];
		}
	}

	float[] sample_buff = new float[1];

	foreach(s_idx; 0..samples) {
		foreach(ref channel; dataset.channels) {
			sample_buff = spectrum_file.rawRead(sample_buff);
			channel.frequency[s_idx] = sample_buff[0];
		}
	}

	foreach(f_idx; 0..(functions - 1)) {
		foreach(s_idx; 0..samples) {
			foreach(ref channel; dataset.channels) {
				sample_buff = spectrum_file.rawRead(sample_buff);
				channel.functions[f_idx].data[s_idx] = sample_buff[0];
			}
		}
	}

	return dataset;
}

void to_aam_sphere(ref Dataset dataset, string output_file, ref ObserverIn observer) {
	
	float theta_delta = (observer.thetaMax.get - observer.thetaMin.get)/(observer.nbTheta.get.to!float - 1);

	// Wopwop calls it psi, aam calls it phi. convert names here
	float phi_delta = (observer.psiMax.get - observer.psiMin.get)/(observer.nbPsi.get.to!float - 1);

	float[] thetas = iota(observer.thetaMin.get, observer.thetaMax.get, theta_delta).map!(a => a.to!float).array;
	float[] phis = iota(observer.psiMin.get, observer.psiMax.get, phi_delta).map!(a => a.to!float).array;

	float[] amplitude;

	size_t channel_idx = 0;

	amplitude = new float[thetas.length*phis.length*dataset.channels[0].frequency.length];

	auto index_swap = observer.indexSwap.isNull ? false : observer.indexSwap.get;
	if(index_swap) {
		foreach(t_idx, theta; thetas) {
			foreach(p_idx, phi; phis) {
				foreach(f_idx; 0..dataset.channels[0].frequency.length) {
					//size_t amp_idx = f_idx + t_idx*dataset.channels[0].frequency.length + p_idx*dataset.channels[0].frequency.length*thetas.length;
					size_t amp_idx = f_idx + p_idx*dataset.channels[0].frequency.length + t_idx*dataset.channels[0].frequency.length*phis.length;
					amplitude[amp_idx] = dataset.channels[channel_idx].functions[2].data[f_idx];
				}
				channel_idx++;
			}
		}
	} else {
		
		foreach(p_idx, phi; phis) {
			foreach(t_idx, theta; thetas) {
				foreach(f_idx; 0..dataset.channels[0].frequency.length) {
					size_t amp_idx = f_idx + t_idx*dataset.channels[0].frequency.length + p_idx*dataset.channels[0].frequency.length*thetas.length;
					amplitude[amp_idx] = dataset.channels[channel_idx].functions[2].data[f_idx];
				}
				channel_idx++;
			}
		}
	}

	int file_handle;

	auto nc_ret = nc_create(output_file.toStringz, NC_WRITE, &file_handle);
	enforce(nc_ret == NC_NOERR, "Failed to create netCDF file");
	scope(exit) nc_close(file_handle);

	int phi_dimid;
	nc_ret = nc_def_dim(file_handle, "PHI_DIM", phis.length, &phi_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define phi dimension");

	int theta_dimid;
	nc_ret = nc_def_dim(file_handle, "THETA_DIM", thetas.length, &theta_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define theta dimension");

	int frequency_dimid;
	nc_ret = nc_def_dim(file_handle, "FREQUENCY_DIM", dataset.channels[0].frequency.length, &frequency_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define frequency dimension");

	int speed_dimid;
	nc_ret = nc_def_dim(file_handle, "MACH_DIM", 1, &speed_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define Mach number dimension");

	int fpa_dimid;
	nc_ret = nc_def_dim(file_handle, "FLIGHT_PATH_ANGLE_DIM", 1, &fpa_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define flight path angle dimension");

	int tilt_dimid;
	nc_ret = nc_def_dim(file_handle, "TILT_ANGLE_DIM", 1, &tilt_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define tilt angle dimension");

	int radius_dimid;
	nc_ret = nc_def_dim(file_handle, "RADIUS_DIM", 1, &radius_dimid);
	enforce(nc_ret == NC_NOERR, "Failed to define radius dimension");

	int phi_varid;
	nc_ret = nc_def_var(file_handle, "PHI", NC_FLOAT, 1, &phi_dimid, &phi_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define phi variable");

	int theta_varid;
	nc_ret = nc_def_var(file_handle, "THETA", NC_FLOAT, 1, &theta_dimid, &theta_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define theta variable");

	int speed_varid;
	nc_ret = nc_def_var(file_handle, "SPEED", NC_FLOAT, 1, &speed_dimid, &speed_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define Mach number variable");

	int fpa_varid;
	nc_ret = nc_def_var(file_handle, "FLIGHT_PATH_ANGLE", NC_FLOAT, 1, &fpa_dimid, &fpa_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define flight path angle variable");

	int tilt_varid;
	nc_ret = nc_def_var(file_handle, "TILT_ANGLE", NC_FLOAT, 1, &tilt_dimid, &tilt_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define tilt angle variable");

	int radius_varid;
	nc_ret = nc_def_var(file_handle, "RADIUS", NC_FLOAT, 1, &radius_dimid, &radius_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define radius variable");

	int amplitude_varid;
	int[3] amplitude_dimids = [phi_dimid, theta_dimid, frequency_dimid];
	nc_ret = nc_def_var(file_handle, "AMPLITUDE", NC_FLOAT, amplitude_dimids.length, amplitude_dimids.ptr, &amplitude_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define amplitude variable");

	int frequency_varid;
	nc_ret = nc_def_var(file_handle, "FREQUENCY", NC_FLOAT, 1, &frequency_dimid, &frequency_varid);
	enforce(nc_ret == NC_NOERR, "Failed to define frequency variable");

	nc_ret = nc_enddef(file_handle);
	enforce(nc_ret == NC_NOERR, "Failed to exit define mode");

	nc_ret = nc_put_var_float(file_handle, radius_varid, &dataset.sphere_radius);
	enforce(nc_ret == NC_NOERR, "Failed to put sphere radius with error "~nc_ret.to!string);
	nc_ret = nc_put_var_float(file_handle, speed_varid, &dataset.speed);
	enforce(nc_ret == NC_NOERR, "Failed to put mach number with error "~nc_ret.to!string);
	nc_ret = nc_put_var_float(file_handle, fpa_varid, &dataset.flight_path_angle);
	enforce(nc_ret == NC_NOERR, "Failed to put flight path angle with error "~nc_ret.to!string);
	nc_ret = nc_put_var_float(file_handle, tilt_varid, &dataset.tilt_angle);
	enforce(nc_ret == NC_NOERR, "Failed to put tilt angle with error "~nc_ret.to!string);

	nc_ret = nc_put_var_float(file_handle, frequency_varid, dataset.channels[0].frequency.ptr);
	enforce(nc_ret == NC_NOERR, "Failed to put frequency with error "~nc_ret.to!string);
	nc_ret = nc_put_var_float(file_handle, phi_varid, phis.ptr);
	enforce(nc_ret == NC_NOERR, "Failed to put phis with error "~nc_ret.to!string);
	nc_ret = nc_put_var_float(file_handle, theta_varid, thetas.ptr);
	enforce(nc_ret == NC_NOERR, "Failed to put thetas with error "~nc_ret.to!string);


	size_t[3] start = 0;
	size_t[3] count = [phis.length, thetas.length, dataset.channels[0].frequency.length];

	nc_ret = nc_put_vara_float(file_handle, amplitude_varid, start.ptr, count.ptr, amplitude.ptr);
	enforce(nc_ret == NC_NOERR, "Failed to put amplitudes with error "~nc_ret.to!string);
}

int main(string[] args) {

	string namelist_file = "";
	string output_file = "./sphere.nc";
	double fpa;
	double tilt_angle;
	double speed;

	arraySep = ",";
	auto help_information = getopt(
		args,
		std.getopt.config.bundling,
		"namelist|n", "Wopwop case namelist to generate one AAM sphere from", &namelist_file,
		"fpa|f", "Flight path angle in degrees", &fpa,
		"tilt|t", "Nacelle tilt angle in degrees", &tilt_angle,
		"speed|s", "Speed in knots", &speed,
		"output|o", "Output file for aam sphere", &output_file
	);

	if(help_information.helpWanted) {
		defaultGetoptPrinter("Program options:", help_information.options);
		import core.stdc.stdlib : exit;
		exit(-1);
	}

	enforce(!fpa.isNaN, "Need to supply a flight path angle for the flight condition");
	enforce(!tilt_angle.isNaN, "Need to supply a nacelle tilt angle for the flight condition");
	enforce(!speed.isNaN, "Need to supply a speed for the flight condition");

	auto namelist = parse_namelist(namelist_file);

	enforce(!namelist.environment_in.spectrumFlag.isNull, "spectrumFlag not specified in namelist. We need spectrum output to continue");
	enforce(namelist.environment_in.spectrumFlag.get, "spectrumFlag set to false in namelist. We need spectrum output to continue");

	if(!namelist.environment_in.ASCIIOutputFlag.isNull) {
		enforce(!namelist.environment_in.ASCIIOutputFlag.get, "ASCIIOutputFlag is set to true. Only binary data files are currently supported");
	}
	
	enforce(namelist.observers.length > 0, "No ObserverIn namelists specified");
	if(namelist.observers.length > 1) {
		writeln("WARNING: More than 1 observer namelist was supplied, only using first one.");
	}

	enforce(!namelist.observers[0].radius.isNull, "No sphere grid radius specified in ObserverIn namelist");
	enforce(!namelist.observers[0].nbTheta.isNull, "nbTheta not specified in ObserverIn namelist");
	enforce(!namelist.observers[0].nbPsi.isNull, "nbPsi not specified in ObserverIn namelist");
	enforce(!namelist.observers[0].thetaMax.isNull, "thetaMax not specified in ObserverIn namelist");
	enforce(!namelist.observers[0].thetaMin.isNull, "thetaMin not specified in ObserverIn namelist");
	enforce(!namelist.observers[0].psiMax.isNull, "psiMax not specified in ObserverIn namelist");
	enforce(!namelist.observers[0].psiMin.isNull, "psiMin not specified in ObserverIn namelist");

	auto output_directory = output_file.dirName;

	if(!output_directory.exists) {
		mkdir(output_directory);
	}

	auto namelist_directory = namelist_file.dirName;

	if(namelist_directory.buildPath("spl_spectrum.fn").exists) {
		auto dataset = read_dataset(namelist_directory, fpa, speed, tilt_angle, namelist.observers[0].radius.get);

		dataset.to_aam_sphere(output_file, namelist.observers[0]);
	} else {
		writeln("ERROR: ", namelist_directory.buildPath("spl_spectrum.fn"), " does not exists. Exiting.");
	}

	return 0;
	
}
