package com.naturalmente.naturalmente

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val ejecutorAudio = Executors.newCachedThreadPool()
    private val cacheSonidos = ConcurrentHashMap<String, ByteArray>()
    private val cacheArchivos = ConcurrentHashMap<String, File>()
    @Volatile
    private var pistaMusica: AudioTrack? = null
    @Volatile
    private var reproductorMusica: MediaPlayer? = null
    @Volatile
    private var musicaActiva: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "naturalmente/audio"
        ).setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "reproducirArchivo" -> {
                    val id = llamada.argument<String>("id") ?: "efecto"
                    val bytes = llamada.argument<ByteArray>("bytes")
                    val ext = llamada.argument<String>("ext") ?: "mp3"
                    if (bytes != null && bytes.isNotEmpty()) {
                        reproducirArchivo(id, bytes, ext)
                    }
                    resultado.success(null)
                }
                "iniciarMusicaArchivo" -> {
                    val bytes = llamada.argument<ByteArray>("bytes")
                    val ext = llamada.argument<String>("ext") ?: "mp3"
                    if (bytes != null && bytes.isNotEmpty()) {
                        iniciarMusicaArchivo(bytes, ext)
                    }
                    resultado.success(null)
                }
                "reproducirPcm" -> {
                    val id = llamada.argument<String>("id")
                    val pcmRecibido = llamada.argument<ByteArray>("pcm")
                    val sampleRate = llamada.argument<Int>("sampleRate") ?: 44100
                    val pcm = if (pcmRecibido != null && pcmRecibido.isNotEmpty()) {
                        if (id != null) {
                            cacheSonidos[id] = pcmRecibido
                        }
                        pcmRecibido
                    } else if (id != null) {
                        cacheSonidos[id]
                    } else {
                        null
                    }
                    if (pcm != null && pcm.isNotEmpty()) {
                        reproducirPcm(pcm, sampleRate)
                    }
                    resultado.success(null)
                }
                "iniciarMusicaPcm" -> {
                    val pcm = llamada.argument<ByteArray>("pcm")
                    val sampleRate = llamada.argument<Int>("sampleRate") ?: 44100
                    if (pcm != null && pcm.isNotEmpty()) {
                        iniciarMusicaPcm(pcm, sampleRate)
                    }
                    resultado.success(null)
                }
                "detenerMusicaPcm" -> {
                    detenerMusicaPcm()
                    resultado.success(null)
                }
                else -> resultado.notImplemented()
            }
        }
    }

    private fun reproducirArchivo(id: String, bytes: ByteArray, ext: String) {
        ejecutorAudio.execute {
            try {
                val clave = "$id.$ext"
                val archivo = cacheArchivos.getOrPut(clave) {
                    val f = File(cacheDir, "sonido_$clave")
                    f.writeBytes(bytes)
                    f
                }
                val mp = MediaPlayer()
                mp.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                mp.setDataSource(archivo.absolutePath)
                mp.setOnCompletionListener { it.release() }
                mp.setOnErrorListener { player, _, _ ->
                    player.release()
                    true
                }
                mp.prepare()
                mp.start()
            } catch (_: Throwable) {
            }
        }
    }

    @Synchronized
    private fun iniciarMusicaArchivo(bytes: ByteArray, ext: String) {
        musicaActiva = true
        ejecutorAudio.execute {
            synchronized(this) {
                try {
                    reproductorMusica?.let {
                        if (it.isPlaying) return@synchronized
                        it.release()
                    }
                    val archivo = File(cacheDir, "musica_fondo.$ext")
                    if (!archivo.exists() || archivo.length().toInt() != bytes.size) {
                        archivo.writeBytes(bytes)
                    }
                    val mp = MediaPlayer()
                    mp.setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    mp.setDataSource(archivo.absolutePath)
                    mp.isLooping = true
                    mp.setVolume(0.55f, 0.55f)
                    mp.prepare()
                    if (musicaActiva) {
                        mp.start()
                        reproductorMusica = mp
                    } else {
                        mp.release()
                    }
                } catch (_: Throwable) {
                }
            }
        }
    }

    private fun reproducirPcm(pcm: ByteArray, sampleRate: Int) {
        ejecutorAudio.execute {
            try {
                val minBuffer = AudioTrack.getMinBufferSize(
                    sampleRate,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT
                )
                val tamanoBuffer = if (minBuffer > pcm.size) minBuffer else pcm.size
                val datos = if (tamanoBuffer > pcm.size) pcm.copyOf(tamanoBuffer) else pcm
                val pista = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(datos.size)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()
                pista.write(datos, 0, datos.size)
                pista.setVolume(1.0f)
                pista.play()
                val duracionMs = (datos.size.toLong() * 500L) / sampleRate.toLong() + 80L
                Thread.sleep(duracionMs)
                pista.stop()
                pista.release()
            } catch (_: Throwable) {
            }
        }
    }

    @Synchronized
    private fun iniciarMusicaPcm(pcm: ByteArray, sampleRate: Int) {
        musicaActiva = true
        ejecutorAudio.execute {
            synchronized(this) {
                try {
                    pistaMusica?.let {
                        if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                            return@synchronized
                        }
                        it.release()
                    }
                    val totalFrames = pcm.size / 2
                    val pista = AudioTrack.Builder()
                        .setAudioAttributes(
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_MEDIA)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .build()
                        )
                        .setAudioFormat(
                            AudioFormat.Builder()
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(sampleRate)
                                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                                .build()
                        )
                        .setBufferSizeInBytes(pcm.size)
                        .setTransferMode(AudioTrack.MODE_STATIC)
                        .build()
                    pista.write(pcm, 0, pcm.size)
                    pista.setLoopPoints(0, totalFrames, -1)
                    pista.setVolume(0.65f)
                    if (musicaActiva) {
                        pista.play()
                        pistaMusica = pista
                    } else {
                        pista.release()
                    }
                } catch (_: Throwable) {
                }
            }
        }
    }

    @Synchronized
    private fun detenerMusicaPcm() {
        musicaActiva = false
        try {
            reproductorMusica?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
            }
        } catch (_: Throwable) {
        } finally {
            reproductorMusica = null
        }
        try {
            pistaMusica?.let {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.stop()
                }
                it.release()
            }
        } catch (_: Throwable) {
        } finally {
            pistaMusica = null
        }
    }

    override fun onPause() {
        try {
            reproductorMusica?.let {
                if (it.isPlaying) {
                    it.pause()
                }
            }
            pistaMusica?.let {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.pause()
                }
            }
        } catch (_: Throwable) {
        }
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        if (musicaActiva) {
            try {
                reproductorMusica?.start()
                pistaMusica?.play()
            } catch (_: Throwable) {
            }
        }
    }

    override fun onDestroy() {
        detenerMusicaPcm()
        super.onDestroy()
    }
}
